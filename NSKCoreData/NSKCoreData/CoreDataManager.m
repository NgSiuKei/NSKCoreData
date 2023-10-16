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
    [self.container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable error) {
        if(error) {
            CDMLog(@"[%@] Fail: error: %@.", self.modelName, error);
            return;
        }
        CDMLog(@"[%@] Success: Load stores.", self.modelName);
        [self parseEntities];
    }];
}

- (void)createEntity:(NSString *)name editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
//    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil.", name);
            if(finishBlock) {
                finishBlock(NO);
            }
            return;
        }
        
        __block NSManagedObjectContext *context = self.container.newBackgroundContext;//self.container.viewContext;
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
        editBlock(entity);
        
        [context performBlock:^{
            if(context.hasChanges) {
                if([context save:nil]) {
                    CDMLog(@"[%@] Success. (thread = %@)", name, [NSThread currentThread]);
                    
                    if(finishBlock) {
                        finishBlock(YES);
                    }
                    return;
                }
                else {
                    CDMLog(@"[%@] Fail: Fail to save.", name);
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
//    }
}

- (void)readEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock {
//    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil.", name);
            if(finishBlock) {
                finishBlock(NO, nil);
            }
            return;
        }
        
        NSManagedObjectContext *context = self.container.viewContext;
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
        if(format) {
            fetch.predicate = [NSPredicate predicateWithFormat:format];
        }
        
        NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
//            [result.finalResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                CDMLog(@"asyn result: obj = %@", obj);
//            }];
            if(result.finalResult) {
                finishBlock(YES, result.finalResult);
            }
            else {
                finishBlock(NO, nil);
            }
        }];
        [context executeRequest:asynFetch error:nil];
        
//        NSArray *entities = [context executeFetchRequest:fetch error:nil];
//        if(entities) {
//            CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
//            if(finishBlock) {
//                finishBlock(YES, entities);
//            }
//        }
//
//        CDMLog(@"[%@] Fail", name);
//        if(finishBlock) {
//            finishBlock(NO, nil);
//        }
//    }
}

- (void)updateEntity:(NSString *)name format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
//    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil.", name);
            if(finishBlock) {
                finishBlock(NO);
            }
        }
        
        __block NSManagedObjectContext *context = self.container.viewContext;
        NSFetchRequest *fetchGroup = [[NSFetchRequest alloc] initWithEntityName:name];
        if(format) {
            fetchGroup.predicate = [NSPredicate predicateWithFormat:format];
        }
        
        NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchGroup completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
            if(result.finalResult) {
//                for(id entity in result.finalResult) {
//                    editBlock(entity);
//                }
                if(editBlock) {
                    [result.finalResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        editBlock(obj);
                    }];
                }
                
                [context performBlock:^{
                    if(context.hasChanges && [context save:nil]) {
                        CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
                        if(finishBlock) {
                            finishBlock(YES);
                        }
                    }
                    else if(!context.hasChanges) {
                        CDMLog(@"[%@] Fail: The context hasn't changes.", name);
                    }
                    else {
                        CDMLog(@"[%@] Fail: Fail to save.", name);
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
        
//        NSArray *entities = [context executeFetchRequest:fetchGroup error:nil];
//        if(entities) {
//            for(id entity in entities) {
//                editBlock(entity);
//            }
//
//            if(context.hasChanges && [context save:nil]) {
//                CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
//                if(finishBlock) {
//                    finishBlock(YES);
//                }
//            }
//            else if(!context.hasChanges) {
//                CDMLog(@"[%@] Fail: The context hasn't changes.", name);
//            }
//            else {
//                CDMLog(@"[%@] Fail: Fail to save.", name);
//            }
//        }
//        else {
//            CDMLog(@"[%@] Fail: No entity matching the format \"%@\" could be found.", name, format);
//        }
//
//        if(finishBlock) {
//            finishBlock(NO);
//        }
//    }
}

- (void)deleteEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
//    @synchronized(self) {
        if(!self.container) {
            CDMLog(@"[%@] Fail: The container is nil.", name);
            if(finishBlock) {
                finishBlock(NO);
            }
            return;
        }
        
        __block NSManagedObjectContext *context = self.container.newBackgroundContext;//self.container.viewContext;
        NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
        if(format) {
            fetch.predicate = [NSPredicate predicateWithFormat:format];
        }
        
        NSAsynchronousFetchRequest *asynFetch = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetch completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
            if(result.finalResult) {
                for(id entity in result.finalResult) {
                    [context deleteObject:entity];
                }
                
                [context performBlock:^{
                    if(context.hasChanges && [context save:nil]) {
                        CDMLog(@"[%@] Success: The format is \"%@\". (thread = %@)", name, format, [NSThread currentThread]);
                        if(finishBlock) {
                            finishBlock(YES);
                        }
                    }
                    else if(!context.hasChanges) {
                        CDMLog(@"[%@] Fail: The context hasn't changes.", name);
                    }
                    else {
                        CDMLog(@"[%@] Fail: Fail to save.", name);
                    }
                }];
            }
            else {
                finishBlock(NO);
            }
        }];
        [context executeRequest:asynFetch error:nil];
        
//        NSArray *entities = [context executeFetchRequest:fetch error:nil];
//        if(entities) {
//            for(id entity in entities) {
//                [context deleteObject:entity];
//            }
//
//            if(context.hasChanges && [context save:nil]) {
//                CDMLog(@"[%@] Success: The format is \"%@\". (thread = %@)", name, format, [NSThread currentThread]);
//                if(finishBlock) {
//                    finishBlock(YES);
//                }
//                return;
//            }
//            else if(!context.hasChanges) {
//                CDMLog(@"[%@] Fail: The context hasn't changes.", name);
//            }
//            else {
//                CDMLog(@"[%@] Fail: Fail to save.", name);
//            }
//        }
//        else {
//            CDMLog(@"[%@] Fail: No entity matching the format \"%@\" could be found.", name, format);
//        }
//
//        CDMLog(@"[%@] Fail", name);
//        if(finishBlock) {
//            finishBlock(NO);
//        }
//        return;
//    }
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
