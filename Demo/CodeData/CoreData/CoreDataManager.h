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

- (instancetype)init:(NSString *)name;
- (BOOL)createEntity:(NSString *)name block:(void(^)(NSManagedObject * _Nonnull entity))block;
- (NSArray *)getEntity:(NSString *)name format:(NSString * _Nullable)format;
- (BOOL)updateEntity:(NSString *)name format:(NSString * _Nullable)format block:(void(^)(NSManagedObject * _Nonnull entity))block;
- (BOOL)deleteEntity:(NSString *)name format:(NSString * _Nullable)format;

@end

NS_ASSUME_NONNULL_END
