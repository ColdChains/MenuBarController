//
//  LCMenuBarScrollView.h
//  LCMenuBarController
//
//  Created by lax on 2021/9/14.
//

#import <UIKit/UIKit.h>
#import "LCMenuBarGestureDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCMenuBarScrollView : UIScrollView

// 手势代理
@property (nonatomic, weak) id<LCMenuBarGestureDelegate> gestureDelegate;

// 是否允许手势传递 默认NO
@property (nonatomic) BOOL shouldRecognizeSimultaneously;

// 手指是否正在按住不可滑动的区域
@property (nonatomic) BOOL isTouching;

@end

NS_ASSUME_NONNULL_END
