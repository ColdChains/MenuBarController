//
//  Tab1ViewController.m
//  MenuBarController
//
//  Created by lax on 2022/5/24.
//

#import "Tab1ViewController.h"
#import "LCMenuBar.h"

#import "ContentViewController.h"

@interface Tab1ViewController ()

@end

@implementation Tab1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置顶部停留间距
    self.headerScrollTopMargin = 0;
    // 关闭切换动画
    self.scrollAnimated = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    headerView.backgroundColor = [UIColor greenColor];
    self.headerView = headerView;
    
    LCMenuBar *menuBar = [[LCMenuBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    menuBar.backgroundColor = [UIColor redColor];
    menuBar.dataArray = @[@"SubTab1", @"SubTab2", @"SubTab3"];
    menuBar.delegate = self;
    self.menuBar = menuBar;
    
    ContentViewController *vc1 = [[ContentViewController alloc] init];
    vc1.view.backgroundColor = [UIColor orangeColor];
    ContentViewController *vc2 = [[ContentViewController alloc] init];
    vc2.view.backgroundColor = [UIColor yellowColor];
    ContentViewController *vc3 = [[ContentViewController alloc] init];
    vc3.view.backgroundColor = [UIColor cyanColor];
    self.viewControllers = @[vc1, vc2, vc3];
}

@end
