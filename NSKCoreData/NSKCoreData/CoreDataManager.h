//
//  ModelManager.h
//  CodeData
//
//  Created by NuSiuKei on 2023/10/2.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObject.h>

#define CDMLog(...) NSLog(@"[CoreDataManager] (%s-%d) %@", __func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataManager : NSObject

/// Initialize with the name of the NSPersistentContainer object.
/// - Parameter name: The name of the NSPersistentContainer object.
- (instancetype)init:(NSString *)name;

/// Create an entity.
/// - Parameters:
///   - name: The name of an entity.
///   - editBlock: Convert the "entity" to the type you need and set its properties.
///   - finishBlock: Show the result of create.  The "isSuccess" indicates whether the creation is successful.
///   - isInMainThread: If you want to run everything in the main thread, set it to true, otherwise set it to false.
- (void)createEntity:(NSString *)name editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock inMainThread:(BOOL)isInMainThread;

/// Read some entities.
/// - Parameters:
///   - name: The name of an entity.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of read. The  "isSuccess" indicates whether the read is successful. The "entities" is an array of entities that are read out.
///   - isInMainThread: If you want to run everything in the main thread, set it to true, otherwise set it to false.
- (void)readEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess, NSArray * _Nullable entities))finishBlock inMainThread:(BOOL)isInMainThread;

/// Update some entities.
/// - Parameters:
///   - name: The name of an entity.
///   - format: Filter format. Write judgment statements for filtering.
///   - editBlock: Convert the "entity" to the type you need and update its properties.
///   - finishBlock: Show the result of update.  The "isSuccess" indicates whether the update is successful.
///   - isInMainThread: If you want to run everything in the main thread, set it to true, otherwise set it to false.
- (void)updateEntity:(NSString *)name format:(NSString * _Nullable)format editBlock:(void(^)(NSManagedObject * _Nonnull entity))editBlock finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock inMainThread:(BOOL)isInMainThread;

/// Update some entities.
/// - Parameters:
///   - name: The name of an entity.
///   - format: Filter format. Write judgment statements for filtering.
///   - finishBlock: Show the result of delete.  The "isSuccess" indicates whether the delete is successful.
///   - isInMainThread: If you want to run everything in the main thread, set it to true, otherwise set it to false.
- (void)deleteEntity:(NSString *)name format:(NSString * _Nullable)format finishBlock:(void(^ _Nullable)(BOOL isSuccess))finishBlock inMainThread:(BOOL)isInMainThread;

@end

NS_ASSUME_NONNULL_END
