//
//  ViewController.m
//  CodeData
//
//  Created by NuSiuKei on 2023/9/29.
//

#import "MainViewController.h"
#import "GroupManagementViewController.h"
#import "Model+CoreDataModel.h"
#import <NSKCoreData/NSKCoreData.h>

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong)UITableView *groupView;
@property(nonatomic,strong)UITableView *deviceView;
@property(nonatomic,strong)UIView *toolBar;

@property(nonatomic,strong)NSArray *groupArray;
@property(nonatomic,strong)NSArray *deviceArray;

@property(nonatomic,assign)int16_t selectedGroupID;
@property(nonatomic,assign)int16_t selectedDeviceID;

@property(nonatomic,strong)CoreDataManager *manager;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildData];
    [self buildUI];
}

#pragma mark - Data
- (void)buildData {
    self.manager = [[CoreDataManager alloc] init:@"Model"];
    [self updateGroupData];
    [self updateDeviceData];
}

- (void)updateGroupData {
    __weak __typeof__(self) weakSelf = self;
    [self.manager readEntity:@"Group" format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entites) {
        __strong __typeof(self) strongSelf = weakSelf;
        if(isSuccess) {
            strongSelf.groupArray = entites;
            for(Group *group in strongSelf.groupArray) {
                CDMLog(@"group = [%d, %@]", group.theID, group.name);
            }
            strongSelf.selectedGroupID = 0;
        }
    }];
}

- (void)updateDeviceData {
    __weak __typeof__(self) weakSelf = self;
    [self.manager readEntity:@"Device" format:nil finishBlock:^(BOOL isSuccess, NSArray * _Nullable entites) {
        __strong __typeof(self) strongSelf = weakSelf;
        if(isSuccess) {
            strongSelf.deviceArray = entites;
            for(Device *device in strongSelf.deviceArray) {
                CDMLog(@"device = [%d, %@]", device.theID, device.name);
            }
            strongSelf.selectedDeviceID = 0;
        }
    }];
}

#pragma mark - UI
- (void)buildUI {
    self.title = @"咩柒";
    [self buildGroupView];
    [self buildDeviceView];
    [self buildToolBar];
}

- (void)buildGroupView {
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame)/2-40;
    self.groupView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.groupView.backgroundColor = UIColor.lightGrayColor;
    self.groupView.delegate = self;
    self.groupView.dataSource = self;
    [self.view addSubview:self.groupView];
}

- (void)buildDeviceView {
    CGRect frame;
    frame.origin.x = CGRectGetMinX(self.groupView.frame);
    frame.origin.y = CGRectGetMaxY(self.groupView.frame);
    frame.size.width = CGRectGetWidth(self.groupView.frame);
    frame.size.height = CGRectGetHeight(self.groupView.frame);
    self.deviceView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.deviceView.backgroundColor = UIColor.darkGrayColor;
    self.deviceView.delegate = self;
    self.deviceView.dataSource = self;
    [self.view addSubview:self.deviceView];
}

- (void)buildToolBar {
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(self.deviceView.frame);
    frame.size.width = CGRectGetWidth(self.deviceView.frame);
    frame.size.height = 80;
    self.toolBar = [[UIView alloc] initWithFrame:frame];
    self.toolBar.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.toolBar];
    
    CGFloat width = (CGRectGetWidth(self.view.frame)-40)/3;
    
    //添加分组
    frame.origin.x = 10;
    frame.origin.y = 10;
    frame.size.width = width;
    frame.size.height = (CGRectGetHeight(self.toolBar.frame)-20-10)/2.0;
    UIButton *addGroupButton = [[UIButton alloc] initWithFrame:frame];
    addGroupButton.backgroundColor = UIColor.blueColor;
    [addGroupButton setTitle:@"添加分组" forState:UIControlStateNormal];
    [addGroupButton addTarget:self action:@selector(addGroupButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:addGroupButton];
    
    //删除分组
    frame.origin.x = CGRectGetMinX(addGroupButton.frame);
    frame.origin.y = CGRectGetMaxY(addGroupButton.frame)+10;
    frame.size.width = CGRectGetWidth(addGroupButton.frame);
    frame.size.height = CGRectGetHeight(addGroupButton.frame);
    UIButton *deleteGroupButton = [[UIButton alloc] initWithFrame:frame];
    deleteGroupButton.backgroundColor = UIColor.redColor;
    [deleteGroupButton setTitle:@"删除分组" forState:UIControlStateNormal];
    [deleteGroupButton addTarget:self action:@selector(deleteGroupButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:deleteGroupButton];
    
    //添加设备
    frame.origin.x = CGRectGetMaxX(addGroupButton.frame)+10;
    frame.origin.y = CGRectGetMinY(addGroupButton.frame);
    frame.size.width = CGRectGetWidth(addGroupButton.frame);
    frame.size.height = CGRectGetHeight(addGroupButton.frame);
    UIButton *addDeviceButton = [[UIButton alloc] initWithFrame:frame];
    addDeviceButton.backgroundColor = UIColor.blueColor;
    [addDeviceButton setTitle:@"添加设备" forState:UIControlStateNormal];
    [addDeviceButton addTarget:self action:@selector(addDeviceButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:addDeviceButton];
    
    //删除设备
    frame.origin.x = CGRectGetMinX(addDeviceButton.frame);
    frame.origin.y = CGRectGetMaxY(addDeviceButton.frame)+10;
    frame.size.width = CGRectGetWidth(addDeviceButton.frame);
    frame.size.height = CGRectGetHeight(addDeviceButton.frame);
    UIButton *deleteDeviceButton = [[UIButton alloc] initWithFrame:frame];
    deleteDeviceButton.backgroundColor = UIColor.redColor;
    [deleteDeviceButton setTitle:@"删除设备" forState:UIControlStateNormal];
    [deleteDeviceButton addTarget:self action:@selector(deleteDeviceButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:deleteDeviceButton];
    
    //分组管理
    frame.origin.x = CGRectGetMaxX(addDeviceButton.frame)+10;
    frame.origin.y = CGRectGetMinY(addDeviceButton.frame);
    frame.size.width = CGRectGetWidth(addDeviceButton.frame);
    frame.size.height = CGRectGetHeight(self.toolBar.frame)-20;
    UIButton *groupManagementButton = [[UIButton alloc] initWithFrame:frame];
    groupManagementButton.backgroundColor = UIColor.blueColor;
    [groupManagementButton setTitle:@"分组管理" forState:UIControlStateNormal];
    [groupManagementButton addTarget:self action:@selector(groupManagementButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:groupManagementButton];
}

#pragma mark - 按钮点击事件
- (void)addGroupButtonClicked {
    __weak __typeof__(self) weakSelf = self;
    [self.manager createEntity:@"Group" editBlock:^(NSManagedObject * _Nonnull entity) {
        __strong __typeof(self) strongSelf = weakSelf;
        Group *newGroup = (Group *)entity;
        newGroup.theID = (int16_t)strongSelf.groupArray.count+1;
        newGroup.name = [NSString stringWithFormat:@"第%lu组", strongSelf.groupArray.count+1];
        newGroup.contain = [NSSet new];
    } finishBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf updateGroupData];
                [strongSelf.groupView reloadData];
            });
        }
    }];
}

- (void)deleteGroupButtonClicked {
    if(0 == self.selectedGroupID) {
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    [self.manager deleteEntity:@"Group" format:[NSString stringWithFormat:@"theID == %d", self.selectedGroupID] finishBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf updateGroupData];
                [strongSelf.groupView reloadData];
            });
        }
    }];
}

- (void)addDeviceButtonClicked {
    __weak __typeof__(self) weakSelf = self;
    [self.manager createEntity:@"Device" editBlock:^(NSManagedObject * _Nonnull entity) {
        __strong __typeof(self) strongSelf = weakSelf;
        Device *newDevice = (Device *)entity;
        newDevice.theID = (int16_t)strongSelf.deviceArray.count+1;
        newDevice.name = [NSString stringWithFormat:@"设备：%lu", strongSelf.deviceArray.count+1];
        newDevice.belong = [NSSet new];
    } finishBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf updateDeviceData];
                [strongSelf.deviceView reloadData];
            });
        }
    }];
}

- (void)deleteDeviceButtonClicked {
    if(0 == self.selectedDeviceID) {
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    [self.manager deleteEntity:@"Device" format:[NSString stringWithFormat:@"theID == %d", self.selectedDeviceID] finishBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(self) strongSelf = weakSelf;
                [strongSelf updateDeviceData];
                [strongSelf.deviceView reloadData];
            });
        }
    }];
}

- (void)groupManagementButtonClicked {
    GroupManagementViewController *vc = [[GroupManagementViewController alloc] init];
    vc.manager = self.manager;
    vc.groupArray = self.groupArray;
    vc.deviceArray = self.deviceArray;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -UITableViewDelegate + UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.groupView) {
        return self.groupArray.count;
    }
    else {
        return self.deviceArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell_%@", indexPath]];
    if(nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell_%@", indexPath]];
    }
    if(tableView == self.groupView) {
        Group *group = self.groupArray[indexPath.row];
        cell.textLabel.text = group.name;
    }
    else {
        Device *device = self.deviceArray[indexPath.row];
        cell.textLabel.text = device.name;
    }
    cell.backgroundColor = UIColor.clearColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.groupView) {
        Group *group = [self.groupArray objectAtIndex:indexPath.row];
        if(self.selectedGroupID != group.theID) {
            self.selectedGroupID = group.theID;
        }
        else {
            self.selectedGroupID = 0;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    else {
        Device *device = [self.deviceArray objectAtIndex:indexPath.row];
        if(self.selectedDeviceID != device.theID) {
            self.selectedDeviceID = device.theID;
        }
        else {
            self.selectedDeviceID = 0;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

@end
