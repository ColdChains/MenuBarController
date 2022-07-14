//
//  ViewController.m
//  LCMenuBarController
//
//  Created by lax on 2022/5/20.
//

#import "ViewController.h"
#import "LCMenuBar.h"

#import "Tab1ViewController.h"
#import "Tab2ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topMargin = 44;
    
    LCMenuBar *menuBar = [[LCMenuBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    menuBar.backgroundColor = [UIColor redColor];
    menuBar.dataArray = @[@"MenuTab1", @"MenuTab2"];
    menuBar.showLineView = YES;
    menuBar.delegate = self;
    self.menuBar = menuBar;
    
    LCMenuBar *footerView = [[LCMenuBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    footerView.backgroundColor = [UIColor redColor];
    footerView.dataArray = @[@"FooterTab1", @"FooterTab2"];
    footerView.delegate = self;
    self.footerView = footerView;
    
    Tab1ViewController *vc1 = [[Tab1ViewController alloc] init];
    vc1.view.backgroundColor = [UIColor darkGrayColor];
    Tab2ViewController *vc2 = [[Tab2ViewController alloc] init];
    vc2.view.backgroundColor = [UIColor lightGrayColor];
    self.viewControllers = @[vc1, vc2];
    
}

@end
