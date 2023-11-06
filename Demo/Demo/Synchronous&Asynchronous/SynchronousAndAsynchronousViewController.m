//
//  SynchronousAndAsynchronousViewController.m
//  Demo
//
//  Created by 伍绍淇 on 2023/11/6.
//

#import "SynchronousAndAsynchronousViewController.h"
#import "SyncAndAsyncDataManager.h"

@interface SynchronousAndAsynchronousViewController ()

@property(nonatomic,strong)SyncAndAsyncDataManager *manager;

@end

@implementation SynchronousAndAsynchronousViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildData];
    [self buildUI];
}

- (void)buildData {
    self.manager = [[SyncAndAsyncDataManager alloc] init];
}

- (void)buildUI {
    self.title = @"Synchronous & Asynchronous";
    self.view.backgroundColor = UIColor.blackColor;
    
    CGRect frame;
    frame.size.width = 200;
    frame.size.height = 50;
    frame.origin.x = 0;
    
    //Main & Sync
    frame.origin.y = 100;
    UIButton *MSButton = [[UIButton alloc] initWithFrame:frame];
    MSButton.backgroundColor = UIColor.whiteColor;
    [MSButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [MSButton setTitle:@"M&S" forState:UIControlStateNormal];
    [MSButton addTarget:self action:@selector(clickMSButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:MSButton];
    
    //Main & Async
    frame.origin.y += 50;
    UIButton *MAButton = [[UIButton alloc] initWithFrame:frame];
    MAButton.backgroundColor = UIColor.redColor;
    [MAButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [MAButton setTitle:@"M&A" forState:UIControlStateNormal];
    [MAButton addTarget:self action:@selector(clickMAButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:MAButton];
    
    //Slaver & Sync
    frame.origin.y += 50;
    UIButton *SSButton = [[UIButton alloc] initWithFrame:frame];
    SSButton.backgroundColor = UIColor.greenColor;
    [SSButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [SSButton setTitle:@"S&S" forState:UIControlStateNormal];
    [SSButton addTarget:self action:@selector(clickSSButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SSButton];
    
    //Slaver & Async
    frame.origin.y += 50;
    UIButton *SAButton = [[UIButton alloc] initWithFrame:frame];
    SAButton.backgroundColor = UIColor.yellowColor;
    [SAButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [SAButton setTitle:@"S&A" forState:UIControlStateNormal];
    [SAButton addTarget:self action:@selector(clickSAButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SAButton];
}

#pragma mark - Button click
- (void)clickMSButton {
    [self.manager testMS];
}

- (void)clickMAButton {
    [self.manager testMA];
}

- (void)clickSSButton {
    [self.manager testSS];
}

- (void)clickSAButton {
    [self.manager testSA];
}

@end
