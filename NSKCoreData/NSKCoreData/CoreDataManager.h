//
//  ModelManager.h
//  CodeData
//
//  Created by NuSiuKei on 2023/10/2.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>

#define CDMLog(...) NSLog(@"[CoreDataManager](%s-%d) %@ {%@}", __func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__], [NSThread currentThread])

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CoreDataManagerContextRunningQueueTypeMain,
    CoreDataManagerContextRunningQueueTypeHeight,
    CoreDataManagerContextRunningQueueTypeDefault,
    CoreDataManagerContextRunningQueueTypeLow,
    CoreDataManagerContextRunningQueueTypeBackground,
} CoreDataManagerContextRunningQueueType;

@interface CoreDataManagerContext : NSObject

/// An NSManagedObjectContext object.
@property(nonatomic,strong)NSManagedObjectContext *context;

/// The queue on which the context runs.
@property(nonatomic,assign)dispatch_queue_t queue;

/// Is the queue running synchronously?
@property(nonatomic,assign)BOOL isSynchronously;

@end

@interface CoreDataManager : NSObject

#pragma mark - Init
/// Initialize manager.
/// - Parameter name: The name of the NSPersistentContainer object.
- (instancetype)init:(NSString *)name;

#pragma mark - Context
/// Get a new context with the type of queue.
/// - Parameter queueType: The type of queue.
- (CoreDataManagerContext *)newContext:(CoreDataManagerContextRunningQueueType)queueType isRunningSynchronously:(BOOL)isRunningSynchronously;

#pragma mark - Create
/// Create an entity synchronously.
/// - Parameters:
///   - name: The name of entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - editBlock: Convert the "entity" to the type you need and set its properties.
///   - finishBlock: Show the result of create.  The "isSuccess" indicates whether the creation is successful.
- (void)syncCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

/// Create an entity asynchronously.
/// - Parameters:
///   - name: The name of entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - editBlock: Convert the "entity" to the type you need and set its properties.
///   - finishBlock: Show the result of create.  The "isSuccess" indicates whether the creation is successful.
- (void)asyncCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

#pragma mark - Batch Create
/// Create an entity in batches synchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - objects: An array of dictionaries that represents objects to insert. Each dictionary contains an attribute name key and a value.
///   - finishBlock: Show the result of create.  The "isSuccess" indicates whether the creation is successful.
- (void)syncBatchCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

/// Create an entity in batches asynchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.   
///   - objects: An array of dictionaries that represents objects to insert. Each dictionary contains an attribute name key and a value.
///   - finishBlock: Show the result of create.  The "isSuccess" indicates whether the creation is successful.
- (void)asyncBatchCreateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context objects:(NSArray<NSDictionary<NSString *,id> *> *)objects finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

#pragma mark - Read
/// Read some entities synchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of read. The  "isSuccess" indicates whether the read is successful. The "entities" is an array of entities that are read out.
- (void)syncReadEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock;

/// Read some entities asynchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of read. The  "isSuccess" indicates whether the read is successful. The "entities" is an array of entities that are read out.
- (void)asyncReadEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock;

#pragma mark - Update
/// Update some entities synchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - editBlock: Convert the "entity" to the type you need and update its properties.
///   - finishBlock: Show the result of update.  The "isSuccess" indicates whether the update is successful.
- (void)syncUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

/// Update some entities asynchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - editBlock: Convert the "entity" to the type you need and update its properties.
///   - finishBlock: Show the result of update.  The "isSuccess" indicates whether the update is successful.
- (void)asyncUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

#pragma mark - Batch Update
/// Update some entities in batches synchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - properties: A dictionary of property description pairs that describe the updates.
///   - finishBlock: Show the result of update.  The "isSuccess" indicates whether the update is successful.
- (void)syncBatchUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

/// Update some entities in batches asynchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.   
///   - properties: A dictionary of property description pairs that describe the updates.
///   - finishBlock: Show the result of update.  The "isSuccess" indicates whether the update is successful.
- (void)asyncBatchUpdateEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context propertiesToUpdate:(NSDictionary<NSString *,id> *)properties finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

#pragma mark - Delete
/// Update some entities synchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of delete.  The "isSuccess" indicates whether the delete is successful.
- (void)syncDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

/// Update some entities asynchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of delete.  The "isSuccess" indicates whether the delete is successful.
- (void)asyncDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

#pragma mark - Batch Delete
/// Update some entities in batches synchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of delete.  The "isSuccess" indicates whether the delete is successful.
- (void)syncBatchDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

/// Update some entities in batches asynchronously.
/// - Parameters:
///   - name: The name of an entity.
///   - context: A CoreDataManagerContext object. If the object is nil, it will be a new background context and running in a default queue asynchronously.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of delete.  The "isSuccess" indicates whether the delete is successful.
- (void)asyncBatchDeleteEntity:(NSString *)name withContext:(CoreDataManagerContext * _Nullable)context format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock;

@end

NS_ASSUME_NONNULL_END
