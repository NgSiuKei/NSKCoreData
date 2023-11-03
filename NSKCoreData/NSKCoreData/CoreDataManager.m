//
//  ModelManager.m
//  CodeData
//
//  Created by NuSiuKei on 2023/10/2.
//

#import "CoreDataManager.h"
#import <CoreData/NSPersistentContainer.h>
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSPropertyDescription.h>
#import <Coredata/NSPersistentStoreResult.h>
#import <Coredata/NSBatchDeleteRequest.h>
#import <Coredata/NSBatchInsertRequest.h>
#import <Coredata/NSBatchUpdateRequest.h>

@interface CoreDataManager ()

@property(nonatomic,strong)NSString *modelName;
@property(nonatomic,strong)NSPersistentContainer *container;
@property(nonatomic,strong)NSManagedObjectContext *mainContext;
@property(nonatomic,strong)NSManagedObjectContext *backgroundContext;

@end

@implementation CoreDataManager

#pragma mark - Init
- (instancetype)init:(NSString *)name {
    self = [super init];
    if(self) {
        self.modelName = name;
        [self createPersistentContainer];
    }
    return self;
}

- (void)createPersistentContainer {
    self.container = [[NSPersistentContainer alloc] initWithName:self.modelName];
    __weak __typeof__(self) weakSelf = self;
    [self.container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if(error) {
            CDMLog(@"[%@] Fail: error: %@.", strongSelf.modelName, error);
            return;
        }
        CDMLog(@"[%@] Success: Load stores.", strongSelf.modelName);
        
        //get main queue
        strongSelf.mainContext = strongSelf.container.viewContext;
        if(!strongSelf.mainContext) {
            CDMLog(@"[%@] Fail: error: The mainContext is nil.", strongSelf.modelName);
            return;
        }
        
        //get private queue
        strongSelf.backgroundContext = strongSelf.container.newBackgroundContext;
        if(!strongSelf.backgroundContext) {
            CDMLog(@"[%@] Fail: error: The backgroundContext is nil.", strongSelf.modelName);
            return;
        }
        
        [strongSelf parseEntities];
    }];
}

#pragma mark - Create
- (void)createEntity:(NSString *)name editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if(!self.mainContext || !self.backgroundContext) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) finishBlock(NO);
        return;
    }
    
    __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
    
    [context performBlock:^{
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
        editBlock(entity);
        
        if(context.hasChanges) {
            NSError *error = nil;
            if([context save:&error]) {
                CDMLog(@"[%@] Success.", name);
                if(finishBlock) finishBlock(YES);
                return;
            }
            else {
                CDMLog(@"[%@] Fail: Fail to save.", name);
            }
            
            if(error) CDMLog(@"[%@] Error: %@.", name, error);
        }
        else {
            CDMLog(@"[%@] Fail: The context hasn't changes.", name);
        }
        
        if(finishBlock) finishBlock(NO);
        return;
    }];
}

- (void)batchCreateEntity:(NSString *)name objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if (@available(iOS 13.0, *)) {
        if(!self.mainContext || !self.backgroundContext) {
            CDMLog(@"[%@] Fail: The contex is nil.", name);
            if(finishBlock) finishBlock(NO);
            return;
        }
        
        __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
        
        NSBatchInsertRequest *createRequest = [[NSBatchInsertRequest alloc] initWithEntityName:name objects:objects];
        createRequest.resultType = NSBatchInsertRequestResultTypeStatusOnly;
        
        [context performBlock:^{
            NSError *error = nil;
            NSBatchDeleteResult * result = [context executeRequest:createRequest error:&error];
            if([result.result boolValue])
                CDMLog(@"[%@] Success: The objects is %@.", name, objects);
            else
                CDMLog(@"[%@] Fail: The objects is %@.", name, objects);
            
            if(error) CDMLog(@"[%@] Error: %@.", name, error);
            
            if(finishBlock) finishBlock([result.result boolValue]);
            
            [context refreshAllObjects];
        }];
    } else {
        CDMLog(@"[%@] Fail: Oss earlier than iOS 13.0 are not supported.", name);
        if(finishBlock) finishBlock(NO);
    }
}

#pragma mark - Read
- (void)readEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock {
    if(!self.mainContext || !self.backgroundContext) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) finishBlock(NO, nil);
        return;
    }
    
    __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    __block void(^readBlock)(NSArray * _Nullable entities) = ^void(NSArray * _Nullable entities) {
        if(entities) {
            CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
            if(finishBlock) finishBlock(YES, entities);
        }
        else {
            if(finishBlock) finishBlock(NO, nil);
        }
    };
    
    if([NSThread isMainThread]) {
        NSError *error = nil;
        NSArray *entities = [context executeFetchRequest:fetch error:&error];
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
        readBlock(entities);
    }
    else {
        NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
            readBlock(result.finalResult);
        }];
        NSError *error = nil;
        [context executeRequest:asynFetch error:&error];
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
    }
}

#pragma mark - Update
- (void)updateEntity:(NSString *)name format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if(!self.mainContext || !self.backgroundContext) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) finishBlock(NO);
        return;
    }
    
    __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    __block void(^updateBlock)(NSArray *entities) = ^void(NSArray *entities) {
        if(entities) {
            if(editBlock) {
                [entities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    editBlock(obj);
                }];
            }
            
            [context performBlock:^{
                if(context.hasChanges) {
                    NSError *error = nil;
                    if([context save:&error]) {
                        CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
                        if(finishBlock) finishBlock(YES);
                        return;
                    }
                    else {
                        CDMLog(@"[%@] Fail: Fail to save", name);
                    }
                    
                    if(error) CDMLog(@"[%@] Error: %@.", name, error);
                }
                else {
                    CDMLog(@"[%@] Fail: The context hasn't changes.", name);
                }
            }];
        }
        else {
            CDMLog(@"[%@] Fail: No entity matching the format \"%@\" could be found.", name, format);
            if(finishBlock) finishBlock(NO);
        }
    };
    
    if([NSThread isMainThread]) {
        NSError *error = nil;
        NSArray *entities = [context executeFetchRequest:fetch error:&error];
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
        updateBlock(entities);
    }
    else {
        NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
            updateBlock(result.finalResult);
        }];
        NSError *error = nil;
        [context executeRequest:asynFetch error:&error];
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
    }
}

- (void)batchUpdateEntity:(NSString *)name propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if(!self.mainContext || !self.backgroundContext) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) finishBlock(NO);
        return;
    }
    
    __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
    
    NSBatchUpdateRequest *updateRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:name];
    updateRequest.resultType = NSStatusOnlyResultType;
    updateRequest.propertiesToUpdate = properties;
    
    [context performBlock:^{
        NSError *error = nil;
        NSBatchDeleteResult * result = [context executeRequest:updateRequest error:&error];
        if([result.result boolValue])
            CDMLog(@"[%@] Success: The properties is %@.", name, properties);
        else
            CDMLog(@"[%@] Fail: The properties is %@.", name, properties);
        
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
        
        if(finishBlock) finishBlock([result.result boolValue]);
        
        [context refreshAllObjects];
    }];
}

#pragma mark - Delete
- (void)deleteEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if(!self.mainContext || !self.backgroundContext) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) finishBlock(NO);
        return;
    }
    
    __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    __block void(^deleteBlock)(NSArray *entities) = ^void(NSArray *entities) {
        if(entities) {
            [entities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [context deleteObject:obj];
            }];
            
            [context performBlock:^{
                if(context.hasChanges) {
                    NSError *error = nil;
                    if([context save:&error]) {
                        CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
                        if(finishBlock) finishBlock(YES);
                        return;
                    }
                    else {
                        CDMLog(@"[%@] Fail: Fail to save.", name);
                    }
                    
                    if(error) CDMLog(@"[%@] Error: %@.", name, error);
                }
                else {
                    CDMLog(@"[%@] Fail: The context hasn't changes.", name);
                }
            }];
        }
        else {
            if(finishBlock) finishBlock(NO);
        }
    };
    
    if([NSThread isMainThread]) {
        [context performBlock:^{
            NSError *error = nil;
            NSArray *entities = [context executeFetchRequest:fetch error:&error];
            if(error) CDMLog(@"[%@] Error: %@.", name, error);
            deleteBlock(entities);
        }];
    }
    else {
        [self.container performBackgroundTask:^(NSManagedObjectContext * _Nonnull newContext) {
            context = newContext;
            [context performBlock:^{
                NSError *error = nil;
                NSArray *entities = [context executeFetchRequest:fetch error:&error];
                if(error) CDMLog(@"[%@] Error: %@.", name, error);
                deleteBlock(entities);
            }];
            
//            NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
//                deleteBlock(result.finalResult);
//            }];
//            NSError *error = nil;
//            [context executeRequest:asynFetch error:&error];
//            if(error) CDMLog(@"[%@] Error: %@.", name, error);
        }];
    }
}

- (void)batchDeleteEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if(!self.mainContext || !self.backgroundContext) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) finishBlock(NO);
        return;
    }
    
    __block NSManagedObjectContext *context = [NSThread isMainThread] ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetch];
    deleteRequest.resultType = NSBatchDeleteResultTypeStatusOnly;
    
    [context performBlock:^{
        NSError *error = nil;
        NSBatchDeleteResult * result = [context executeRequest:deleteRequest error:&error];
        if([result.result boolValue])
            CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
        else
            CDMLog(@"[%@] Fail: The format is \"%@\".", name, format);
        
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
        
        if(finishBlock) finishBlock([result.result boolValue]);
        
        [context refreshAllObjects];
    }];
}

#pragma mark - Other
- (void)parseEntities {
    NSArray *entities = self.container.managedObjectModel.entities;
    CDMLog(@"[%@] Entity count = %lu", self.modelName, entities.count);
    for(NSEntityDescription *entity in entities) {
        CDMLog(@"[%@] Entity name = %@", self.modelName, entity.name);
        for(NSPropertyDescription *property in entity.properties) {
            CDMLog(@"[%@] Property name = %@", self.modelName, property.name);
        }
    }
}

@end
