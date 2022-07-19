//
//  LCMenuBarScrollController.h
//  MenuBarController
//
//  Created by lax on 2021/9/10.
//

#import <UIKit/UIKit.h>
#import "LCMenuBarScrollView.h"

#import "LCMenuBarProtocol.h"
#import "LCMenuBarScrollViewDelegate.h"
#import "LCMenuBarDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCMenuBarController : UIViewController <UIScrollViewDelegate, LCMenuBarDelegate>

// 竖向滚动视图代理
@property (nonatomic, weak) id<LCMenuBarScrollViewDelegate> delegate;

// 默认下标 默认0 需在设置viewControllers之前设置
@property (nonatomic) NSInteger defaultIndex;

// 当前显示的控制器下标
@property (nonatomic, assign, readonly) NSInteger currentIndex;

// 当前显示的控制器
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

// 当前显示控制器内的滚动视图
@property (nonatomic, strong, readonly) UIScrollView *currentScrollView;

// 竖向滚动视图
@property (nonatomic, strong, readonly) LCMenuBarScrollView *verticalScrollView;

// 横向滚动视图
@property (nonatomic, strong, readonly) LCMenuBarScrollView *horizontalScrollView;

// 是否点击状态栏
@property (nonatomic, assign, readonly) BOOL touchStatusBar;

// 竖向滚动视图最大偏移量
@property (nonatomic, assign, readonly) CGFloat verticalMaxOffset;

// 此属性控制竖向滚动视图能否滚动 默认NO 设置YES则不会控制滚动
@property (nonatomic) BOOL notHandleVerticalScrollView;

// 此属性控制内部滚动视图能否滚动 默认NO 设置YES则不会控制滚动
@property (nonatomic) BOOL notHandleChildScrollView;

// MARK: 个性化定制

// 内容是否嵌套 默认YES 设置NO则没有竖向滚动视图
@property (nonatomic) BOOL shouldNested;

// 竖向滚动视图是否有弹性 默认NO
@property (nonatomic) BOOL bounces;

// 点击状态栏滚动视图是否回到顶部 默认YES
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

// 头视图高度是否自适应 默认NO
@property (nonatomic) BOOL headerAutoHeight;

// 菜单视图高度是否自适应 默认NO
@property (nonatomic) BOOL menuAutoHeight;

// 尾视图高度是否自适应 默认NO
@property (nonatomic) BOOL footerAutoHeight;

// MARK: 内容定制

// 头视图
@property (nonatomic, strong, nullable) UIView *headerView;

// 菜单视图
@property (nonatomic, strong, nullable) UIView *menuBar;

// 尾视图
@property (nonatomic, strong, nullable) UIView *footerView;

// 子控制器数组
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

/// 构造方法
/// @param viewControllers 子控制器数组
- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers;

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

/// 控制器加载完成
/// @param vc 控制器
- (void)menuBarControllerDidLoadViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
