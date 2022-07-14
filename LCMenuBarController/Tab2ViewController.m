//
//  Tab2ViewController.m
//  LCMenuBarController
//
//  Created by lax on 2022/7/8.
//

#import "Tab2ViewController.h"
#import <Masonry/Masonry.h>

@interface Tab2ViewController ()

@end

@implementation Tab2ViewController

// 状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:UIScreen.mainScreen.bounds];
    label.text = @"SubScrollView";
    label.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:label];
    
    scrollView.tag = 100;
    scrollView.contentSize = UIScreen.mainScreen.bounds.size;
}

@end
