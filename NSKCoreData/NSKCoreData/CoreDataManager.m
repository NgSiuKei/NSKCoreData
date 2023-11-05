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

#define NSK_WeakSelf __weak __typeof__(self) weakSelf = self;
#define NSK_StrongSelf __strong __typeof(self) strongSelf = weakSelf;

@implementation CoreDataManagerContext

@end

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

#pragma mark - Context
- (CoreDataManagerContext *)newContext:(CoreDataManagerContextRunningQueueType)queueType isRunningSynchronously:(BOOL)isRunningSynchronously {
    CoreDataManagerContext *context = [CoreDataManagerContext new];
    if(CoreDataManagerContextRunningQueueTypeMain == queueType) {
        context.context = self.container.viewContext;
        context.queue = dispatch_get_main_queue();
    }
    else {
        int queue = DISPATCH_QUEUE_PRIORITY_DEFAULT;
        switch (queueType) {
            case CoreDataManagerContextRunningQueueTypeHeight:
                queue = DISPATCH_QUEUE_PRIORITY_HIGH; break;
            case CoreDataManagerContextRunningQueueTypeDefault:
                queue = DISPATCH_QUEUE_PRIORITY_DEFAULT; break;
            case CoreDataManagerContextRunningQueueTypeLow:
                queue = DISPATCH_QUEUE_PRIORITY_LOW; break;
            case CoreDataManagerContextRunningQueueTypeBackground:
                queue = DISPATCH_QUEUE_PRIORITY_BACKGROUND; break;
            default: break;
        }
        context.context = self.container.newBackgroundContext;
        context.queue = dispatch_get_global_queue(queue, 0);
    }
    context.isSynchronously = isRunningSynchronously;
    return context;
}

#pragma mark - Create
- (void)syncCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self createEntity:name withContext:context editBlock:editBlock finishBlock:finishBlock isSync:YES];
}

- (void)asyncCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self createEntity:name withContext:context editBlock:editBlock finishBlock:finishBlock isSync:NO];
}

#pragma mark - Batch Create
- (void)syncBatchCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self batchCreateEntity:name withContext:context objects:objects finishBlock:finishBlock isSync:YES];
}

- (void)asyncBatchCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self batchCreateEntity:name withContext:context objects:objects finishBlock:finishBlock isSync:NO];
}

#pragma mark - Read
- (void)syncReadEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock {
    [self readEntity:name withContext:context format:format finishBlock:finishBlock isSync:YES];
}

- (void)asyncReadEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock {
    [self readEntity:name withContext:context format:format finishBlock:finishBlock isSync:NO];
}

#pragma mark - Update
- (void)syncUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self updateEntity:name withContext:context format:format editBlock:editBlock finishBlock:finishBlock isSync:YES];
}

- (void)asyncUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self updateEntity:name withContext:context format:format editBlock:editBlock finishBlock:finishBlock isSync:NO];
}

#pragma mark - Batch Update
- (void)syncBatchUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self batchUpdateEntity:name withContext:context propertiesToUpdate:properties finishBlock:finishBlock isSync:YES];
}

- (void)asyncBatchUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self batchUpdateEntity:name withContext:context propertiesToUpdate:properties finishBlock:finishBlock isSync:NO];
}

#pragma mark - Delete
- (void)syncDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self deleteEntity:name withContext:context format:format finishBlock:finishBlock isSync:YES];
}

- (void)asyncDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self deleteEntity:name withContext:context format:format finishBlock:finishBlock isSync:NO];
}

#pragma mark - Batch Delete
- (void)syncBatchDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self batchDeleteEntity:name withContext:context format:format finishBlock:finishBlock isSync:YES];
}

- (void)asyncBatchDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    [self batchDeleteEntity:name withContext:context format:format finishBlock:finishBlock isSync:NO];
}

#pragma mark - Execute synchronously or asynchronously
- (void)executeWorkBlock:(void(^)(NSManagedObjectContext *context))block withContext:(CoreDataManagerContext * _Nullable)context isSynchronously:(BOOL)isSync {
    void(^workBlock)(NSManagedObjectContext *context) = ^void(NSManagedObjectContext *context) {
        if(isSync) {
            [context performBlockAndWait:^{
                block(context);
            }];
        }
        else {
            [context performBlock:^{
                block(context);
            }];
        }
    };
    
    if(context) {
        if(context.isSynchronously) {
            dispatch_sync(context.queue, ^{
                workBlock(context.context);
            });
        }
        else {
            dispatch_async(context.queue, ^{
                workBlock(context.context);
            });
        }
    }
    else {
        [self.container performBackgroundTask:^(NSManagedObjectContext * _Nonnull newContext) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                workBlock(newContext);
            });
        }];
    }
}

#pragma mark - Create synchronously or asynchronously
- (void)createEntity:(NSString *)name withContext:(CoreDataManagerContext *)context editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseCreateEntity:name withContext:context editBlock:editBlock finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Batch create synchronously or asynchronously
- (void)batchCreateEntity:(NSString *)name withContext:(CoreDataManagerContext *)context objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseBatchCreateEntity:name withContext:context objects:objects finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Read synchronously or asynchronously
- (void)readEntity:(NSString *)name withContext:(CoreDataManagerContext *)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseReadEntity:name withContext:context format:format finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Update synchronously or asynchronously
- (void)updateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseUpdateEntity:name withContext:context format:format editBlock:editBlock finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Batch update synchronously or asynchronously
- (void)batchUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock  isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseBatchUpdateEntity:name withContext:context propertiesToUpdate:properties finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Delete synchronously or asynchronously
- (void)deleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseDeleteEntity:name withContext:context format:format finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Batch delete synchronously or asynchronously
- (void)batchDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock isSync:(BOOL)isSync {
    NSK_WeakSelf
    [self executeWorkBlock:^(NSManagedObjectContext *context) {
        NSK_StrongSelf
        [strongSelf baseBatchDeleteEntity:name withContext:context format:format finishBlock:finishBlock];
    } withContext:context isSynchronously:isSync];
}

#pragma mark - Base create
- (void)baseCreateEntity:(NSString *)name withContext:(NSManagedObjectContext *)context editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    //Create and edit.
    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
    editBlock(entity);
    //Save.
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
}

#pragma mark - Base batch create
- (void)baseBatchCreateEntity:(NSString *)name withContext:(NSManagedObjectContext *)context objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    if (@available(iOS 13.0, *)) {
        NSBatchInsertRequest *createRequest = [[NSBatchInsertRequest alloc] initWithEntityName:name objects:objects];
        createRequest.resultType = NSBatchInsertRequestResultTypeStatusOnly;
        
        NSError *error = nil;
        NSBatchDeleteResult * result = [context executeRequest:createRequest error:&error];
        if([result.result boolValue])
            CDMLog(@"[%@] Success: The objects is %@.", name, objects);
        else
            CDMLog(@"[%@] Fail: The objects is %@.", name, objects);
        
        if(error) CDMLog(@"[%@] Error: %@.", name, error);
        
        if(finishBlock) finishBlock([result.result boolValue]);
        
        [context refreshAllObjects];
    }
    else {
        CDMLog(@"[%@] Fail: Oss earlier than iOS 13.0 are not supported.", name);
        if(finishBlock) finishBlock(NO);
    }
}

#pragma mark - Base read
- (void)baseReadEntity:(NSString *)name withContext:(NSManagedObjectContext *)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock {
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
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:fetch error:&error];
    if(error) CDMLog(@"[%@] Error: %@.", name, error);
    readBlock(entities);
}

#pragma mark - Base update
- (void)baseUpdateEntity:(NSString *)name withContext:(NSManagedObjectContext *)context format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
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
        }
        else {
            CDMLog(@"[%@] Fail: No entity matching the format \"%@\" could be found.", name, format);
            if(finishBlock) finishBlock(NO);
        }
    };
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:fetch error:&error];
    if(error) CDMLog(@"[%@] Error: %@.", name, error);
    updateBlock(entities);
}

#pragma mark - Base batch update
- (void)baseBatchUpdateEntity:(NSString *)name withContext:(NSManagedObjectContext *)context propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    
    NSBatchUpdateRequest *updateRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:name];
    updateRequest.resultType = NSStatusOnlyResultType;
    updateRequest.propertiesToUpdate = properties;
    
    NSError *error = nil;
    NSBatchDeleteResult * result = [context executeRequest:updateRequest error:&error];
    if([result.result boolValue])
        CDMLog(@"[%@] Success: The properties is %@.", name, properties);
    else
        CDMLog(@"[%@] Fail: The properties is %@.", name, properties);
    
    if(error) CDMLog(@"[%@] Error: %@.", name, error);
    
    if(finishBlock) finishBlock([result.result boolValue]);
    
    [context refreshAllObjects];
}

#pragma mark - Base delete
- (void)baseDeleteEntity:(NSString *)name withContext:(NSManagedObjectContext *)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    __block void(^deleteBlock)(NSArray *entities) = ^void(NSArray *entities) {
        if(entities) {
            [entities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [context deleteObject:obj];
            }];
            
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
        }
        else {
            if(finishBlock) finishBlock(NO);
        }
    };
    
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:fetch error:&error];
    if(error) CDMLog(@"[%@] Error: %@.", name, error);
    deleteBlock(entities);
}

#pragma mark - Base batch delete
- (void)baseBatchDeleteEntity:(NSString *)name withContext:(NSManagedObjectContext *)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock {
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:name];
    if(format) {
        fetch.predicate = [NSPredicate predicateWithFormat:format];
    }
    
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetch];
    deleteRequest.resultType = NSBatchDeleteResultTypeStatusOnly;
    
    NSError *error = nil;
    NSBatchDeleteResult * result = [context executeRequest:deleteRequest error:&error];
    if([result.result boolValue])
        CDMLog(@"[%@] Success: The format is \"%@\".", name, format);
    else
        CDMLog(@"[%@] Fail: The format is \"%@\".", name, format);
    
    if(error) CDMLog(@"[%@] Error: %@.", name, error);
    
    if(finishBlock) finishBlock([result.result boolValue]);
    
    [context refreshAllObjects];
}

@end
