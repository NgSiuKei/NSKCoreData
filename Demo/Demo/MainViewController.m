//
//  ViewController.m
//  Demo
//
//  Created by 伍绍淇 on 2023/10/29.
//

#import "MainViewController.h"
#import "BasicUseViewController.h"
#import "SynchronousAndAsynchronousViewController.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
}

#pragma mark - UI
- (void)buildUI {
    self.title = @"Demo";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell_%@", indexPath]];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell_%@", indexPath]];
    }
    
    if(0 == indexPath.row) {
        cell.textLabel.text = @"Basic Use";
    }
    else if(1 == indexPath.row) {
        cell.textLabel.text = @"Synchronous & Asynchronous";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Choice One";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(0 == indexPath.row) {
        BasicUseViewController *vc = [[BasicUseViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(1 == indexPath.row) {
        SynchronousAndAsynchronousViewController *vc = [[SynchronousAndAsynchronousViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
