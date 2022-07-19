//
//  LCMenuBarDelegate.h
//  MenuBarController
//
//  Created by lax on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LCMenuBarScrollViewTypeVertical,   // 竖向滚动视图
    LCMenuBarScrollViewTypeHorizontal, // 横向滚动视图
    LCMenuBarScrollViewTypeMenu,       // 菜单滚动视图
    LCMenuBarScrollViewTypeChild,      // 内部滚动视图
} LCMenuBarScrollViewType;

@protocol LCMenuBarScrollViewDelegate <NSObject>

@optional

// 正在滚动
- (void)menuBarScrollViewDidScroll:(UIScrollView *_Nullable)scrollView type:(LCMenuBarScrollViewType)type;

// 开始拖拽
- (void)menuBarScrollViewWillBeginDragging:(UIScrollView *_Nullable)scrollView type:(LCMenuBarScrollViewType)type;

// 停止拖拽
- (void)menuBarScrollViewDidEndDragging:(UIScrollView *_Nullable)scrollView willDecelerate:(BOOL)decelerate type:(LCMenuBarScrollViewType)type;

// 开始滚动
- (void)menuBarScrollViewWillBeginDecelerating:(UIScrollView *_Nullable)scrollView type:(LCMenuBarScrollViewType)type;

// 停止滚动
- (void)menuBarScrollViewDidEndDecelerating:(UIScrollView *_Nullable)scrollView type:(LCMenuBarScrollViewType)type;

@end

NS_ASSUME_NONNULL_END

