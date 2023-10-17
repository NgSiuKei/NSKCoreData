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

@interface CoreDataManager ()

@property(nonatomic,strong)NSString *modelName;
@property(nonatomic,strong)NSPersistentContainer *container;
@property(nonatomic,strong)NSManagedObjectContext *mainContext;
@property(nonatomic,strong)NSManagedObjectContext *backgroundContext;

@end

@implementation CoreDataManager
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

- (void)createEntity:(NSString *)name editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock inMainThread:(BOOL)isInMainThread {
    if((isInMainThread && !self.mainContext) || (!isInMainThread && !self.backgroundContext)) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) {
            finishBlock(NO);
        }
        return;
    }
    
    __block NSManagedObjectContext *context = isInMainThread ? self.mainContext : self.backgroundContext;
    
    [context performBlock:^{
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
        editBlock(entity);
        
        if(context.hasChanges) {
            NSError *error = nil;
            if([context save:&error]) {
                CDMLog(@"[%@] Success.", name);
                if(finishBlock) {
                    finishBlock(YES);
                }
                return;
            }
            else {
                CDMLog(@"[%@] Fail: Fail to save. The error is \"%@\"", name, error);
            }
        }
        else {
            CDMLog(@"[%@] Fail: The context hasn't changes.", name);
        }
        
        if(finishBlock) {
            finishBlock(NO);
        }
        return;
    }];
}

- (void)readEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock inMainThread:(BOOL)isInMainThread {
    if((isInMainThread && !self.mainContext) || (!isInMainThread && !self.backgroundContext)) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) {
            finishBlock(NO, nil);
        }
        return;
    }
    
    NSManagedObjectContext *context = isInMainThread ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        if(result.finalResult) {
            CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
            finishBlock(YES, result.finalResult);
        }
        else {
            finishBlock(NO, nil);
        }
    }];
    [context executeRequest:asynFetch error:nil];
}

- (void)updateEntity:(NSString *)name format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock inMainThread:(BOOL)isInMainThread {
    if((isInMainThread && !self.mainContext) || (!isInMainThread && !self.backgroundContext)) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) {
            finishBlock(NO);
        }
        return;
    }
    
    __block NSManagedObjectContext *context = isInMainThread ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetchGroup = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetchGroup.predicate = [NSPredicate predicateWithFormat:format];
    }
        
    NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchGroup completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        if(result.finalResult) {
            if(editBlock) {
                [result.finalResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    editBlock(obj);
                }];
            }
            
            [context performBlock:^{
                if(context.hasChanges) {
                    NSError *error = nil;
                    if([context save:&error]) {
                        CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
                        if(finishBlock) {
                            finishBlock(YES);
                        }
                        return;
                    }
                    else {
                        CDMLog(@"[%@] Fail: Fail to save. The error is \"%@\"", name, error);
                    }
                }
                else {
                    CDMLog(@"[%@] Fail: The context hasn't changes.", name);
                }
            }];
        }
        else {
            CDMLog(@"[%@] Fail: No entity matching the format \"%@\" could be found.", name, format);
            if(finishBlock) {
                finishBlock(NO);
            }
        }
    }];
    [context executeRequest:asynFetch error:nil];
}

- (void)deleteEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock inMainThread:(BOOL)isInMainThread {
    if((isInMainThread && !self.mainContext) || (!isInMainThread && !self.backgroundContext)) {
        CDMLog(@"[%@] Fail: The contex is nil.", name);
        if(finishBlock) {
            finishBlock(NO);
        }
        return;
    }
    
    __block NSManagedObjectContext *context = isInMainThread ? self.mainContext : self.backgroundContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        if(result.finalResult) {
            [result.finalResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [context deleteObject:obj];
            }];
            
            [context performBlock:^{
                if(context.hasChanges) {
                    NSError *error = nil;
                    if([context save:&error]) {
                        CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
                        if(finishBlock) {
                            finishBlock(YES);
                        }
                        return;
                    }
                    else {
                        CDMLog(@"[%@] Fail: Fail to save. The error is \"%@\"", name, error);
                    }
                }
                else {
                    CDMLog(@"[%@] Fail: The context hasn't changes.", name);
                }
            }];
        }
        else {
            finishBlock(NO);
        }
    }];
    [context executeRequest:asynFetch error:nil];
}

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
