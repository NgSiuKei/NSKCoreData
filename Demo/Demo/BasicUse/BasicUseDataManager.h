//
//  DataManager.h
//  Demo
//
//  Created by 伍绍淇 on 2023/10/28.
//

#import <Foundation/Foundation.h>
#import "What+CoreDataClass.h"
#import "NSKCoreData/NSKCoreData.h"

NS_ASSUME_NONNULL_BEGIN

#define NSK_WeakSelf __weak __typeof__(self) weakSelf = self;
#define NSK_StrongSelf __strong __typeof(self) strongSelf = weakSelf;

#define kUUID @"uuid"
#define kStr @"str"
#define kNumber @"number"

@protocol BasicUseDataManagerDelegate <NSObject>

@required
-(void)operateSuccess:(NSArray<NSDictionary *> *)param;
-(void)operateFail;

@optional

@end

@interface BasicUseDataManager : NSObject

- (instancetype)init:(CoreDataManagerContextRunningQueueType)type isSync:(BOOL)isSync;

//Simple Function
- (void)add;
- (void)remove:(NSUUID *)uuid;
- (void)read;
- (void)update:(NSUUID *)uuid;

@property(nonatomic,strong)id<BasicUseDataManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
