//
//  Tab1ViewController.m
//  LCMenuBarController
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
    
    self.headerScrollTopMargin = 44;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
