//
//  ContentViewController.m
//  LCMenuBarController
//
//  Created by lax on 2022/5/24.
//

#import "ContentViewController.h"
#import "LCMenuBarProtocol.h"
#import <Masonry/Masonry.h>

@interface ContentViewController () <LCMenuBarProtocol>

@end

@implementation ContentViewController

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

- (UIScrollView *)lcScrollView {
    return [self.view viewWithTag:100];
}

@end
