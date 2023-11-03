//
//  DataManager.m
//  Demo
//
//  Created by 伍绍淇 on 2023/10/28.
//

#import "DataManager.h"
#import "NSKCoreData/NSKCoreData.h"

#define eWhat @"What"

@interface DataManager()

@property(nonatomic,strong)CoreDataManager *manager;

@end

@implementation DataManager

- (instancetype)init {
    self = [super init];
    if(self) {
        self.manager = [[CoreDataManager alloc] init:@"Model"];
    }
    return self;
}

-(void)add {
    NSK_WeakSelf
    [self.manager createEntity:eWhat editBlock:^(NSManagedObject * _Nonnull entity) {
        What *what = (What *)entity;
        what.uuid = [NSUUID UUID];
        what.str = [what.uuid UUIDString];
        what.number = 0;
    } finishBlock:^(BOOL isSuccess) {
        NSK_StrongSelf
        [strongSelf finishBlock:isSuccess];
    }];
}
-(void)remove:(NSUUID *)uuid {
    NSK_WeakSelf
    [self.manager deleteEntity:eWhat format:[NSString stringWithFormat:@"str LIKE \"%@\"", uuid.UUIDString] finishBlock:^(BOOL isSuccess) {
        NSK_StrongSelf
        [strongSelf finishBlock:isSuccess];
    }];
}

-(void)read {
    NSK_WeakSelf
    [self.manager readEntity:eWhat format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entities) {
        NSK_StrongSelf
        if(strongSelf.delegate) {
            if(isSuccess && [self.delegate respondsToSelector:@selector(operateSuccess:)])
                [strongSelf.delegate operateSuccess:entities];
            else if([self.delegate respondsToSelector:@selector(operateFail)])
                [strongSelf.delegate operateFail];
        }
    }];
}

-(void)update:(NSUUID *)uuid {
    NSK_WeakSelf
    [self.manager updateEntity:eWhat format:[NSString stringWithFormat:@"str LIKE \"%@\"", uuid.UUIDString] editBlock:^(NSManagedObject * _Nonnull entity) {
        What *what = (What *)entity;
        what.number += 1;
    } finishBlock:^(BOOL isSuccess) {
        NSK_StrongSelf
        [strongSelf finishBlock:isSuccess];
    }];
}

-(void)finishBlock:(BOOL)isSuccess {
    if(isSuccess)
        [self read];
    else if(self.delegate && [self.delegate respondsToSelector:@selector(operateFail)])
        [self.delegate operateFail];
}

@end
