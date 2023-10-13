//
//  GroupManagementViewController.m
//  CodeData
//
//  Created by NuSiuKei on 2023/9/30.
//

#import "GroupManagementViewController.h"
#import "Model+CoreDataModel.h"

@interface GroupManagementViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong)UITableView *groupView;
@property(nonatomic,strong)UITableView *deviceView;
@property(nonatomic,strong)UIView *toolBar;

@property(nonatomic,assign)int16_t selectedGroupID;
@property(nonatomic,assign)int16_t selectedDeviceID;

@end

@implementation GroupManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
}

#pragma mark - UI
- (void)buildUI {
    self.title = @"咩卵";
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
    
    CGFloat width = (CGRectGetWidth(self.view.frame)-30)/2;
    
    //添加设备
    frame.origin.x = 10;
    frame.origin.y = 10;
    frame.size.width = width;
    frame.size.height = CGRectGetHeight(self.toolBar.frame)-20;
    UIButton *addDeviceButton = [[UIButton alloc] initWithFrame:frame];
    addDeviceButton.backgroundColor = UIColor.blueColor;
    [addDeviceButton setTitle:@"添加设备" forState:UIControlStateNormal];
    [addDeviceButton addTarget:self action:@selector(addDeviceButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:addDeviceButton];
    
    //删除设备
    frame.origin.x = CGRectGetMaxX(addDeviceButton.frame)+10;
    frame.origin.y = CGRectGetMinY(addDeviceButton.frame);
    frame.size.width = CGRectGetWidth(addDeviceButton.frame);
    frame.size.height = CGRectGetHeight(addDeviceButton.frame);
    UIButton *deleteDeviceButton = [[UIButton alloc] initWithFrame:frame];
    deleteDeviceButton.backgroundColor = UIColor.redColor;
    [deleteDeviceButton setTitle:@"删除设备" forState:UIControlStateNormal];
    [deleteDeviceButton addTarget:self action:@selector(deleteDeviceButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:deleteDeviceButton];
}

#pragma mark - Data
- (void)updateData {
    
}

#pragma mark - 按钮点击事件
- (void)addDeviceButtonClicked {
    __weak __typeof__(self) weakSelf = self;
//    [self.manager changeEntity:@"Device" format:[NSString stringWithFormat:@"theID == %d", self.selectedDeviceID] block:^(NSManagedObject * _Nonnull entity) {
    [self.manager updateEntity:@"Device" format:@"theID == 1" editBlock:^(NSManagedObject * _Nonnull entity) {
        __strong __typeof(self) strongSelf = weakSelf;
        Group *group = [strongSelf.groupArray objectAtIndex:0];
        
        Device *device = (Device *)entity;
        NSMutableSet *groups = [device.belong mutableCopy];
        [groups addObject:group];
        device.belong = [groups copy];
    } finishBlock:nil];
}

- (void)deleteDeviceButtonClicked {
    Group *group = [self.groupArray objectAtIndex:0];
    NSMutableSet *devices = [group.contain mutableCopy];
    Device *device = [self.deviceArray objectAtIndex:0];
    NSMutableSet *groups = [device.belong mutableCopy];
    CDMLog(@"group theID = %d contain = %@", group.theID, devices);
    CDMLog(@"device theID = %d belong = %@", device.theID, groups);
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
