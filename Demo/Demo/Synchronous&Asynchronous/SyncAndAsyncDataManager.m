//
//  SyncAndAsyncDataManager.m
//  Demo
//
//  Created by 伍绍淇 on 2023/11/6.
//

#import "SyncAndAsyncDataManager.h"
#import "NSKCoreData/NSKCoreData.h"

@interface SyncAndAsyncDataManager ()

@property(nonatomic,strong)CoreDataManager *manager;
@property(nonatomic,strong)CoreDataManagerContext *contextMS;
@property(nonatomic,strong)CoreDataManagerContext *contextMA;
@property(nonatomic,strong)CoreDataManagerContext *contextSS;
@property(nonatomic,strong)CoreDataManagerContext *contextSA;

@end

@implementation SyncAndAsyncDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[CoreDataManager alloc] init:@"Model"];
        self.contextMS = [self.manager newContext:CoreDataManagerContextRunningQueueTypeMain isRunningSynchronously:YES];
        self.contextMA = [self.manager newContext:CoreDataManagerContextRunningQueueTypeMain isRunningSynchronously:NO];
        self.contextSS = [self.manager newContext:CoreDataManagerContextRunningQueueTypeHeight isRunningSynchronously:YES];
        self.contextSA = [self.manager newContext:CoreDataManagerContextRunningQueueTypeHeight isRunningSynchronously:NO];
    }
    return self;
}

- (void)testMS {
    //It will deadlock if it runs on the main thread. So runs on a slaver thread. 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for(int i=0; i<5; ++i) {
            __block int number = i;
            [self.manager asyncReadEntity:@"What" withContext:self.contextMS format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entities) {
                NSLog(@"Test MS: %d", number);
            }];
        }
    });
}

- (void)testMA {
    for(int i=0; i<5; ++i) {
        __block int number = i;
        [self.manager asyncReadEntity:@"What" withContext:self.contextMA format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entities) {
            NSLog(@"Test MA: %d", number);
        }];
    }
}

- (void)testSS {
    for(int i=0; i<5; ++i) {
        __block int number = i;
        [self.manager asyncReadEntity:@"What" withContext:self.contextSS format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entities) {
            NSLog(@"Test SS: %d", number);
        }];
    }
}

- (void)testSA {
    for(int i=0; i<5; ++i) {
        __block int number = i;
        [self.manager asyncReadEntity:@"What" withContext:self.contextSA format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entities) {
            NSLog(@"Test SA: %d", number);
        }];
    }
}

@end
