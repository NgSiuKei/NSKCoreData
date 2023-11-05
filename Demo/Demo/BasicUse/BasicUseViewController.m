//
//  BasicUseViewController.m
//  Demo
//
//  Created by 伍绍淇 on 2023/10/29.
//

#import "BasicUseViewController.h"
#import "DataManager.h"

@interface BasicUseViewController ()<UITableViewDelegate, UITableViewDataSource, DataManagerDelegate>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)DataManager *manager;

@property(nonatomic,strong)NSArray *data;
@property(nonatomic,strong)NSDictionary *selectedParam;

@end

@implementation BasicUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildData];
    [self buildUI];
}

#pragma mark - Data
- (void)buildData {
    self.manager = [[DataManager alloc] init];
    self.manager.delegate = self;
    [self.manager read];
}

#pragma mark - UI
- (void)buildUI {
    self.title = @"Basic Use";
    
    CGRect frame;
    
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame)-50;
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(self.tableView.frame);
    frame.size.width = CGRectGetWidth(self.tableView.frame)/3;
    frame.size.height = 50;
    UIButton *buttonAdd = [[UIButton alloc] initWithFrame:frame];
    [buttonAdd setTitle:@"Add" forState:UIControlStateNormal];
    [buttonAdd setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [buttonAdd setBackgroundColor:UIColor.greenColor];
    [buttonAdd addTarget:self action:@selector(buttonAddClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonAdd];
    
    frame.origin.x = CGRectGetMaxX(buttonAdd.frame);
    UIButton *buttonUpdate = [[UIButton alloc] initWithFrame:frame];
    [buttonUpdate setTitle:@"Update" forState:UIControlStateNormal];
    [buttonUpdate setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [buttonUpdate setBackgroundColor:UIColor.yellowColor];
    [buttonUpdate addTarget:self action:@selector(buttonUpdateClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonUpdate];
    
    frame.origin.x = CGRectGetMaxX(buttonUpdate.frame);
    UIButton *buttonDelete = [[UIButton alloc] initWithFrame:frame];
    [buttonDelete setTitle:@"Delete" forState:UIControlStateNormal];
    [buttonDelete setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [buttonDelete setBackgroundColor:UIColor.redColor];
    [buttonDelete addTarget:self action:@selector(buttonDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonDelete];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data?self.data.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *param = [self.data objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell_%@", param[kUUID]]];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"cell_%@", param[kUUID]]];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"UUID:%@", param[kUUID]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"number = %@", param[kNumber]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Let's Gooooooooooooo~~~~~~~";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedParam = [self.data objectAtIndex:indexPath.row];
}

#pragma mark - DataManagerDelegate
- (void)operateSuccess:(NSArray<NSDictionary *> *)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.data =[param mutableCopy];
        if(self.tableView) [self.tableView reloadData];
    });
}

- (void)operateFail {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.data = [NSArray new];
        if(self.tableView) [self.tableView reloadData];
    });
}

#pragma mark - Button Click
- (void)buttonAddClick {
    [self.manager add];
}

-(void)buttonDeleteClick {
    if(self.selectedParam) {
        [self.manager remove:self.selectedParam[kUUID]];
        self.selectedParam = nil;
    }
}

-(void)buttonUpdateClick {
    if(self.selectedParam) {
        [self.manager update:self.selectedParam[kUUID]];
        self.selectedParam = nil;
    }
}

@end
