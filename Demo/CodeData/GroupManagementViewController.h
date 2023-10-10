//
//  GroupManagementViewController.h
//  CodeData
//
//  Created by NuSiuKei on 2023/9/30.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupManagementViewController : UIViewController

@property(nonatomic,strong)CoreDataManager *manager;
@property(nonatomic,strong)NSArray *groupArray;
@property(nonatomic,strong)NSArray *deviceArray;

@end

NS_ASSUME_NONNULL_END
