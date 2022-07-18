//
//  LCMenuBarMenuDelegate.h
//  LCMenuBarController
//
//  Created by lax on 2021/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LCMenuBarLineAlignment) {
    LCMenuBarLineAlignmentLeft       = -1,
    LCMenuBarLineAlignmentCenter     = 0,
    LCMenuBarLineAlignmentRight      = 1,
};

@protocol LCMenuBarDelegate <UIScrollViewDelegate>

@optional

// 点击菜单按钮
- (void)menuBarDidSelect:(UIView<LCMenuBarDelegate> *)menuBar atIndex:(NSInteger)currentIndex;

@end

NS_ASSUME_NONNULL_END
