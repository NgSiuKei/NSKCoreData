//
//  DataManager.h
//  Demo
//
//  Created by 伍绍淇 on 2023/10/28.
//

#import <Foundation/Foundation.h>
#import "What+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

#define NSK_WeakSelf __weak __typeof__(self) weakSelf = self;
#define NSK_StrongSelf __strong __typeof(self) strongSelf = weakSelf;

@protocol DataManagerDelegate <NSObject>

@required
-(void)operateSuccess:(NSArray<What *> *)whats;
-(void)operateFail;

@optional

@end

@interface DataManager : NSObject

//Simple Function
-(void)add;
-(void)remove:(NSUUID *)uuid;
-(void)read;
-(void)update:(NSUUID *)uuid;

@property(nonatomic,strong)id<DataManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
