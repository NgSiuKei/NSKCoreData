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
@property(nonatomic,strong)What *selectedWhat;

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
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    What *what = [self.data objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell_%@", what.uuid]];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"cell_%@", what.uuid]];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"UUID:%@", what.uuid];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"number = %d", what.number];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Let's Gooooooooooooo~~~~~~~";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedWhat = [self.data objectAtIndex:indexPath.row];
}

#pragma mark - DataManagerDelegate
- (void)operateSuccess:(NSArray<What *> *)whats {
    self.data = [whats mutableCopy];
    [self.tableView reloadData];
}

- (void)operateFail {
    self.data = [NSArray new];
    [self.tableView reloadData];
}

#pragma mark - Button Click
- (void)buttonAddClick {
    [self.manager add];
}

-(void)buttonDeleteClick {
    if(self.selectedWhat) {
        NSK_WeakSelf
        __block NSUUID *uuid = [self.selectedWhat.uuid copy];
        [self.manager remove:self.selectedWhat.uuid];
        self.selectedWhat = nil;
    }
}

-(void)buttonUpdateClick {
    if(self.selectedWhat) {
        [self.manager update:self.selectedWhat.uuid];
        self.selectedWhat = nil;
    }
}

-(void)test {
    NSLog(@"TestTestTestTestTestTestTestTestTestTestTest");
}

@end
