//
//  Tab2ViewController.m
//  MenuBarController
//
//  Created by lax on 2022/7/8.
//

#import "Tab2ViewController.h"
#import <Masonry/Masonry.h>
#import "RootViewController.h"

@interface Tab2ViewController ()

@end

@implementation Tab2ViewController

// 修改状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIButton *button = [[UIButton alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [button setTitle:@"SubScrollView" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
    
    scrollView.tag = 100;
    scrollView.contentSize = UIScreen.mainScreen.bounds.size;
}

- (void)buttonAction {
    
}

@end
