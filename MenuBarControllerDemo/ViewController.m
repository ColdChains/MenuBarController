//
//  AppDelegate.h
//  MenuBarControllerDemo
//
//  Created by lax on 2022/7/18.
//

#import "ViewController.h"
#import "Tab1ViewController.h"
#import "Tab2ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置顶部间距
    self.topMargin = 44;
    
    LCMenuBar *menuBar = [[LCMenuBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    menuBar.backgroundColor = [UIColor redColor];
    menuBar.dataArray = @[@"MenuTab1", @"MenuTab2"];
    menuBar.showLineView = YES;
    menuBar.delegate = self;
    // 设置菜单栏
    self.menuBar = menuBar;
    
    UILabel *footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    footerView.backgroundColor = [UIColor redColor];
    footerView.text = @"FooterView";
    footerView.textAlignment = NSTextAlignmentCenter;
    // 设置底部视图
    self.footerView = footerView;
    
    Tab1ViewController *vc1 = [[Tab1ViewController alloc] init];
    vc1.view.backgroundColor = [UIColor darkGrayColor];
    Tab2ViewController *vc2 = [[Tab2ViewController alloc] init];
    vc2.view.backgroundColor = [UIColor lightGrayColor];
    // 设置子控制器
    self.viewControllers = @[vc1, vc2];
    
}


@end
