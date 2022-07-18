//
//  LCMenuBarView.h
//  LCMenuBarController
//
//  Created by lax on 2021/9/16.
//

#import <UIKit/UIKit.h>
#import "LCMenuBarScrollView.h"

#import "LCMenuBarProtocol.h"
#import "LCMenuBarScrollViewDelegate.h"
#import "LCMenuBarDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCMenuBarView : UIView <UIScrollViewDelegate, LCMenuBarDelegate>

// 竖向滚动视图代理
@property (nonatomic, weak) id<LCMenuBarScrollViewDelegate> delegate;

// 默认下标 默认0 需在设置views之前设置
@property (nonatomic) NSInteger defaultIndex;

// 当前显示的视图下标
@property (nonatomic, assign, readonly) NSInteger currentIndex;

// 当前显示的视图
@property (nonatomic, strong, readonly) UIView *currentView;

// 当前显示视图内的滚动视图
@property (nonatomic, strong, readonly) UIScrollView *currentScrollView;

// 竖向滚动视图
@property (nonatomic, strong, readonly) LCMenuBarScrollView *verticalScrollView;

// 横向滚动视图
@property (nonatomic, strong, readonly) LCMenuBarScrollView *horizontalScrollView;

// 竖向滚动视图最大偏移量
@property (nonatomic, assign, readonly) CGFloat verticalMaxOffset;

// 是否点击状态栏
@property (nonatomic, assign, readonly) BOOL touchStatusBar;

// 此属性控制竖向滚动视图能否滚动 默认NO 设置YES则不会控制滚动
@property (nonatomic) BOOL notHandleVerticalScrollView;

// 此属性控制内部滚动视图能否滚动 默认NO 设置YES则不会控制滚动
@property (nonatomic) BOOL notHandleChildScrollView;

// MARK: 个性化定制

// 内容是否嵌套 默认YES 设置NO则没有竖向滚动视图
@property (nonatomic) BOOL shouldNested;

// 竖向滚动视图下拉是否有弹性 默认NO
@property (nonatomic) BOOL bounces;

// 点击状态栏子视图是否回到顶部 默认YES
@property (nonatomic) BOOL scrollsToTop;

// 点击菜单切换时是否有动画 默认YES
@property (nonatomic) BOOL scrollAnimated;

// 头部滑到顶部后下拉是否可固定 默认NO
@property (nonatomic) BOOL headerCanFixed;

// 是否可拖拽菜单上下滑动 默认NO
@property (nonatomic) BOOL menuCanDrag;

// MARK: UI定制

// 竖向滚动视图顶部间距
@property (nonatomic) CGFloat topMargin;

// 竖向滚动视图底部的间距
@property (nonatomic) CGFloat bottomMargin;

// 头视图停留时顶部的间距
@property (nonatomic) CGFloat headerScrollTopMargin;

// 头视图底部与菜单的间距
@property (nonatomic) CGFloat headerBottomMargin;

// 菜单底部的间距
@property (nonatomic) CGFloat menuBottomMargin;

// 头视图高度是否自适应  默认NO
@property (nonatomic) BOOL headerAutoHeight;

// 菜单视图高度是否自适应  默认NO
@property (nonatomic) BOOL menuAutoHeight;

// 尾视图高度是否自适应  默认NO
@property (nonatomic) BOOL footerAutoHeight;

// MARK: 内容定制

// 头视图
@property (nonatomic, strong, nullable) UIView *headerView;

// 尾视图
@property (nonatomic, strong, nullable) UIView *footerView;

// 菜单视图
@property (nonatomic, strong, nullable) UIView *menuBar;

// 子视图数组
@property (nonatomic, strong) NSArray<UIView *> *views;

/// 竖向滚动视图回到顶部
/// @param animated 动画
- (void)scrollToTopWithAnimated:(BOOL)animated;

/// 子视图回到顶部
/// @param animated 动画
- (void)subScrollViewScrollToTopWithAnimated:(BOOL)animated;

/// 滑动到指定控制器
/// @param currentIndex 控制器下标
/// @param animated 动画
- (void)scrollToIndex:(NSInteger)currentIndex animated:(BOOL)animated;

/// 菜单是否需要选中 默认返回YES 返回NO则滑动子视图时菜单不会有选中态
/// @param currentIndex 当前位置
- (BOOL)menuBarShouldChangeAtIndex:(NSInteger)currentIndex;

/// 菜单选中事件
/// @param currentIndex 当前位置
- (void)menuBarDidChangedAtIndex:(NSInteger)currentIndex;

@end

NS_ASSUME_NONNULL_END
