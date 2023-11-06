//
//  DataManager.m
//  Demo
//
//  Created by 伍绍淇 on 2023/10/28.
//

#import "BasicUseDataManager.h"

#define eWhat @"What"

@interface BasicUseDataManager()

@property(nonatomic,strong)CoreDataManager *manager;
@property(nonatomic,strong)CoreDataManagerContext *context;

@end

@implementation BasicUseDataManager

- (instancetype)init:(CoreDataManagerContextRunningQueueType)type isSync:(BOOL)isSync {
    self = [super init];
    if(self) {
        self.manager = [[CoreDataManager alloc] init:@"Model"];
        self.context = [self.manager newContext:type isRunningSynchronously:isSync];
    }
    return self;
}

- (void)add {
    NSK_WeakSelf
    [self.manager asyncCreateEntity:eWhat withContext:self.context editBlock:^(NSManagedObject * _Nonnull entity) {
        What *what = (What *)entity;
        what.uuid = [NSUUID UUID];
        what.str = [what.uuid UUIDString];
        what.number = 0;
    } finishBlock:^(BOOL isSuccess) {
        NSK_StrongSelf
        [strongSelf finishBlock:isSuccess];
    }];
}

- (void)remove:(NSUUID *)uuid {
    NSK_WeakSelf
    [self.manager asyncDeleteEntity:eWhat withContext:self.context format:[NSString stringWithFormat:@"str LIKE \"%@\"", uuid.UUIDString] finishBlock:^(BOOL isSuccess) {
        NSK_StrongSelf
        [strongSelf finishBlock:isSuccess];
    }];
}

- (void)read {
    NSK_WeakSelf
    [self.manager asyncReadEntity:eWhat withContext:self.context format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entities) {
        NSK_StrongSelf
        if(strongSelf.delegate) {
            if(isSuccess && [self.delegate respondsToSelector:@selector(operateSuccess:)]) {
                NSMutableArray *param = [NSMutableArray new];
                for(What *what in entities) {
                    [param addObject:@{
                        kUUID:what.uuid,
                        kStr:what.str,
                        kNumber:@(what.number),
                    }];
                }
                [strongSelf.delegate operateSuccess:param];
            }
            else if([self.delegate respondsToSelector:@selector(operateFail)]) {
                [strongSelf.delegate operateFail];
            }
        }
    }];
}

- (void)update:(NSUUID *)uuid {
    NSK_WeakSelf
    [self.manager asyncUpdateEntity:eWhat withContext:self.context format:[NSString stringWithFormat:@"str LIKE \"%@\"", uuid.UUIDString] editBlock:^(NSManagedObject * _Nonnull entity) {
        What *what = (What *)entity;
        what.number += 1;
    } finishBlock:^(BOOL isSuccess) {
        NSK_StrongSelf
        [strongSelf finishBlock:isSuccess];
    }];
}

- (void)finishBlock:(BOOL)isSuccess {
    if(isSuccess)
        [self read];
    else if(self.delegate && [self.delegate respondsToSelector:@selector(operateFail)])
        [self.delegate operateFail];
}

@end
