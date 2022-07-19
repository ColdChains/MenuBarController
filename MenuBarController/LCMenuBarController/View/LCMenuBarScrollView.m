//
//  LCMenuBarScrollView.m
//  MenuBarController
//
//  Created by lax on 2021/9/14.
//

#import "LCMenuBarScrollView.h"
#import "LCMenuBarView.h"

#import "LCMenuBarDelegate.h"

@implementation LCMenuBarScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.delaysContentTouches = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.isTouching = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.isTouching = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

// 多个滚动视图同时响应手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIResponder *responder = otherGestureRecognizer.view;
    // 两个都是竖向滚动视图时返回YES
    if ([responder isKindOfClass:LCMenuBarScrollView.class]) {
        return self.shouldRecognizeSimultaneously && ((LCMenuBarScrollView *)responder).shouldRecognizeSimultaneously;
    }
    // 根据代理判断responder是否是联动的ScrollView
    if ([self.gestureDelegate respondsToSelector:@selector(menuBarGestureShouldRecognizeSimultaneously:)]) {
        return [self.gestureDelegate menuBarGestureShouldRecognizeSimultaneously:responder];
    }
    return NO;
}

// 避免拖拽菜单时事件被拦截不滚动
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    [super touchesShouldCancelInContentView:view];
    return YES;
}

// 拖拽按钮时不调用touchesBegan 在这里设置isTouching
- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    if ([self isInMenuBar:view]) {
        self.isTouching = YES;
    }
    return YES;
}

// 判断视图是否在菜单内
- (BOOL)isInMenuBar:(UIView *)view {
    if (![view isKindOfClass:[LCMenuBarView class]] && [view conformsToProtocol:@protocol(LCMenuBarDelegate)]) {
        return YES;
    } else {
        UIView *targetView = view;
        while (targetView.superview) {
            targetView = targetView.superview;
            if (![targetView isKindOfClass:[LCMenuBarView class]] && [targetView conformsToProtocol:@protocol(LCMenuBarDelegate)]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
