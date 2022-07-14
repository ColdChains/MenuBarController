//
//  LCMenuBarScrollController.m
//  LCMenuBarController
//
//  Created by lax on 2021/9/10.
//

#import "LCMenuBarController.h"
#import "LCMenuBarObserverDelegate.h"
#import "LCMenuBarProtocol.h"
#import <Masonry/Masonry.h>

@interface LCMenuBarController () <LCMenuBarObserverDelegate, LCMenuBarGestureDelegate>

// 观察者代理
@property (nonatomic, weak) id<LCMenuBarObserverDelegate> observerDelegate;

// 是否点击状态栏
@property (nonatomic) BOOL touchStatusBar;

// 竖向滚动视图是否可滑动 默认YES
@property (nonatomic) CGFloat outsideCanScroll;

// 内部滚动视图是否可滑动 默认NO
@property (nonatomic) CGFloat insideCanScroll;

// 滚动视图偏移量记录
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *offsetDictionary;

// 添加观察者记录
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *observerDictionary;

// 页面生命周期管理 记录将要消失的页面
@property (nonatomic) NSInteger lastAppearanceIndex;

// 页面生命周期管理 记录是否有页面出现
@property (nonatomic) BOOL haveAppearancex;

// 弹性管理 记录竖向滚动视图是否有弹性
@property (nonatomic) BOOL alwaysBounceHorizontal;

@end

@implementation LCMenuBarController

// MARK: - Getter Setter

- (NSMutableDictionary<NSString *,NSNumber *> *)offsetDictionary {
    if (!_offsetDictionary) {
        _offsetDictionary = [NSMutableDictionary dictionary];
    }
    return _offsetDictionary;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)observerDictionary {
    if (!_observerDictionary) {
        _observerDictionary = [NSMutableDictionary dictionary];
    }
    return _observerDictionary;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    
    // 竖向滚动视图不能滚动时 动态设置当前显示控制器的scrollsToTop
    if (self.verticalScrollView.contentSize.height <= self.verticalScrollView.frame.size.height && self.scrollsToTop) {
        self.verticalScrollView.scrollsToTop = NO;
        [self scrollViewFromViewController:self.currentViewController].scrollsToTop = NO;
    }
    
    _currentIndex = currentIndex;
    
    // 竖向滚动视图不能滚动时 动态设置当前显示控制器的scrollsToTop
    if (self.verticalScrollView.contentSize.height <= self.verticalScrollView.frame.size.height && self.scrollsToTop) {
        [self scrollViewFromViewController:self.currentViewController].scrollsToTop = YES;
    }
    
    [self menuBarWillChangeAtIndex:currentIndex];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIViewController *)currentViewController {
    if (self.currentIndex >= 0 && self.currentIndex < self.viewControllers.count) {
        return self.viewControllers[self.currentIndex];
    }
    return nil;
}

- (UIScrollView *)currentScrollView {
    return [self scrollViewFromViewController:self.currentViewController];
}

- (CGFloat)verticalMaxOffset {
    return _headerView ? (_headerView.frame.size.height + _headerBottomMargin - _headerScrollTopMargin) : 0;
}

- (void)setShouldNested:(BOOL)shouldNested {
    _shouldNested = shouldNested;
    if (!self.isViewLoaded) { return; }
    
    if (shouldNested) {
        if (!_verticalScrollView) {
            _verticalScrollView = [[LCMenuBarScrollView alloc] init];
            _verticalScrollView.delegate = self;
            _verticalScrollView.gestureDelegate = self;
            _verticalScrollView.shouldRecognizeSimultaneously = YES;
            [self.view addSubview:_verticalScrollView];
            [self layoutVerticalScrollView];
            // 添加观察者
            if (_verticalScrollView && ![self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]]) {
                [self.observerDictionary setValue:@(1) forKey:[NSString stringWithFormat:@"%p", _verticalScrollView]];
                [_verticalScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            }
        }
    } else {
        // 移除观察者
        if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]]) {
            [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]];
            [_verticalScrollView removeObserver:self forKeyPath:@"contentOffset"];
        }
        [_verticalScrollView removeFromSuperview];
        _verticalScrollView = nil;
    }
    
    [self.verticalScrollView ?: self.view addSubview:self.horizontalScrollView];
    [self.horizontalScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.horizontalScrollView.superview);
        make.height.mas_equalTo(self.horizontalScrollView.superview);
    }];
    if (self.headerView) {
        [self.headerView removeFromSuperview];
        [self.verticalScrollView ?: self.view addSubview:self.headerView];
        [self layoutHeaderView];
    }
    if (self.menuBar) {
        [self.headerView removeFromSuperview];
        [self.verticalScrollView ?: self.view addSubview:self.menuBar];
        [self layoutMenuBar];
    }
    if (self.footerView) {
        [self.headerView removeFromSuperview];
        [self.verticalScrollView ?: self.view addSubview:self.footerView];
        [self layoutFooterView];
    }
    [self layoutHorizontalScrollView];
    
    if (self.viewControllers) {
        self.viewControllers = _viewControllers;
    }
    
}

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    _scrollsToTop = scrollsToTop;
    self.verticalScrollView.scrollsToTop = scrollsToTop;
}

- (void)setTopMargin:(CGFloat)topMargin {
    _topMargin = topMargin;
    if (!self.isViewLoaded) { return; }
    if (self.shouldNested) {
        [self layoutVerticalScrollView];
    } else {
        [self layoutHeaderView];
        [self layoutMenuBar];
        [self layoutHorizontalScrollView];
    }
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    if (!self.isViewLoaded) { return; }
    if (self.shouldNested) {
        [self layoutFooterView];
        [self layoutVerticalScrollView];
    } else {
        [self layoutFooterView];
        [self layoutHorizontalScrollView];
    }
}

- (void)setHeaderScrollTopMargin:(CGFloat)headerScrollTopMargin {
    _headerScrollTopMargin = headerScrollTopMargin;
    if (!self.isViewLoaded) { return; }
    [self layoutHorizontalScrollViewHeight];
}

- (void)setHeaderBottomMargin:(CGFloat)headerBottomMargin {
    _headerBottomMargin = headerBottomMargin;
    if (!self.isViewLoaded) { return; }
    [self layoutHorizontalScrollViewHeight];
    if (!self.headerView) { return; }
    if (self.menuBar) {
        [self layoutMenuBar];
    } else {
        [self layoutHorizontalScrollView];
    }
}

- (void)setMenuBottomMargin:(CGFloat)menuBottomMargin {
    _menuBottomMargin = menuBottomMargin;
    if (!self.isViewLoaded) { return; }
    if (!self.menuBar) { return; }
    [self layoutHorizontalScrollView];
}

- (void)setHeaderAutoHeight:(BOOL)headerAutoHeight {
    _headerAutoHeight = headerAutoHeight;
    if (!self.isViewLoaded) { return; }
    [self layoutHeaderView];
}

- (void)setMenuAutoHeight:(BOOL)menuAutoHeight {
    _menuAutoHeight = menuAutoHeight;
    if (!self.isViewLoaded) { return; }
    [self layoutMenuBar];
}

- (void)setFooterAutoHeight:(BOOL)footerAutoHeight {
    _footerAutoHeight = footerAutoHeight;
    if (!self.isViewLoaded) { return; }
    [self layoutFooterView];
}

- (void)setHeaderView:(UIView *)headerView {
    [_headerView removeFromSuperview];
    _headerView = headerView;
    if (!self.isViewLoaded) { return; }
    if (headerView) {
        [self.verticalScrollView ?: self.view addSubview:headerView];
        [self layoutHeaderView];
    }
    if (self.menuBar) {
        [headerView.superview insertSubview:headerView belowSubview:self.menuBar];
        [self layoutMenuBar];
    }
    [self layoutHorizontalScrollView];
}

- (void)setMenuBar:(UIView *)menuBar {
    [_menuBar removeFromSuperview];
    _menuBar = menuBar;
    if (!self.isViewLoaded) { return; }
    [self.verticalScrollView ?: self.view addSubview:menuBar];
    [self layoutMenuBar];
    [self layoutHorizontalScrollView];
}

- (void)setFooterView:(UIView *)footerView {
    [_footerView removeFromSuperview];
    _footerView = footerView;
    if (!self.isViewLoaded) { return; }
    if (!footerView) { return; }
    [self.view addSubview:footerView];
    [self layoutFooterView];
    [self layoutVerticalScrollView];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    
    [self removeSubViewControllerObserver];
    for (UIViewController *vc in _viewControllers) {
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    _viewControllers = viewControllers;
    
    if (!self.horizontalScrollView) { return; }
    if (viewControllers.count == 0) { return; }
    if (!self.isViewLoaded) { return; }
    
    [self.view layoutIfNeeded];
    self.horizontalScrollView.contentSize = CGSizeMake(viewControllers.count * self.horizontalScrollView.bounds.size.width, 0);
    
    [self loadChildViewControllerAtIndex:self.defaultIndex];
    
    [self scrollToIndex:self.defaultIndex animated:NO];
    
    [self.offsetDictionary removeAllObjects];
    
}

// MARK: - layout

- (void)layoutVerticalScrollView {
    if (!self.verticalScrollView.superview) { return; }
    [self.verticalScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topMargin);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.footerView ? self.footerView.mas_top : self.verticalScrollView.superview).offset(self.footerView ? 0 : -self.bottomMargin);
    }];
}

- (void)layoutHorizontalScrollView {
    if (!self.horizontalScrollView.superview) { return; }
    [self.horizontalScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.menuBar ? self.menuBar.mas_bottom : self.headerView ? self.headerView.mas_bottom : self.horizontalScrollView.superview).offset(self.menuBar ? self.menuBottomMargin : self.headerView ? self.headerBottomMargin : 0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.footerView ? 0 : self.shouldNested ? 0 : -self.bottomMargin);
        if (self.shouldNested) {
            make.width.mas_equalTo(self.horizontalScrollView.superview);
            make.height.mas_equalTo(self.horizontalScrollView.superview);
        }
    }];
    if (self.shouldNested) {
        [self layoutHorizontalScrollViewHeight];
    }
}

- (void)layoutHorizontalScrollViewHeight {
    if (!self.horizontalScrollView.superview) { return; }
    CGFloat horizontalViewHeightOffset = (self.headerView ? _headerScrollTopMargin : 0) + (self.menuBar ? (self.menuBar.frame.size.height + self.menuBottomMargin) : 0);
    [self.horizontalScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.horizontalScrollView.superview).offset(-horizontalViewHeightOffset);
    }];
}

- (void)layoutMenuBar {
    if (!self.menuBar.superview) { return; }
    [self.menuBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView ? self.headerView.mas_bottom : self.menuBar.superview).offset(self.headerView ? self.headerBottomMargin : (self.shouldNested ? 0 : self.topMargin));
        make.left.right.mas_equalTo(0);
        make.width.mas_equalTo(self.menuBar.superview);
        if (!self.menuAutoHeight) {
            make.height.mas_equalTo(self.menuBar.frame.size.height);
        }
    }];
}

- (void)layoutHeaderView {
    if (!self.headerView.superview) { return; }
    [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shouldNested ? 0 : self.topMargin);
        make.left.right.mas_equalTo(0);
        make.width.mas_equalTo(self.headerView.superview);
        if (!self.headerAutoHeight) {
            make.height.mas_equalTo(self.headerView.frame.size.height);
        }
    }];
}

- (void)layoutFooterView {
    if (!self.footerView.superview) { return; }
    [self.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.shouldNested ? 0 : -self.bottomMargin);
        make.width.mas_equalTo(self.footerView.superview);
        if (!self.footerAutoHeight) {
            make.height.mas_equalTo(self.footerView.frame.size.height);
        }
    }];
}

// MARK: - 生命周期管理

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self beginAppearanceTransitionWithNewIndex:self.currentIndex oldIndex:-1];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [self endAppearanceTransitionWithNewIndex:self.currentIndex oldIndex:-1];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self beginAppearanceTransitionWithNewIndex:-1 oldIndex:self.currentIndex];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self endAppearanceTransitionWithNewIndex:-1 oldIndex:self.currentIndex];
    [super viewDidDisappear:animated];
}

// oldIndex消失 newIndex出现
- (void)appearanceTransitionWithNewIndex:(NSInteger)newIndex oldIndex:(NSInteger)oldIndex {
    if (newIndex == oldIndex) { return; }
    if (oldIndex >= 0 && oldIndex < self.viewControllers.count) {
        [self.viewControllers[oldIndex] beginAppearanceTransition:NO animated:NO];
    }
    if (newIndex >= 0 && newIndex < self.viewControllers.count) {
        [self.viewControllers[newIndex] beginAppearanceTransition:YES animated:NO];
    }
    if (oldIndex >= 0 && oldIndex < self.viewControllers.count) {
        [self.viewControllers[oldIndex] endAppearanceTransition];
    }
    if (newIndex >= 0 && newIndex < self.viewControllers.count) {
        [self.viewControllers[newIndex] endAppearanceTransition];
    }
}

// newIndex将要出现 oldIndex将要消失
- (void)beginAppearanceTransitionWithNewIndex:(NSInteger)newIndex oldIndex:(NSInteger)oldIndex {
    if (newIndex == oldIndex) { return; }
    self.haveAppearancex = YES;
    if (oldIndex >= 0 && oldIndex < self.viewControllers.count) {
        self.lastAppearanceIndex = oldIndex;
        [self.viewControllers[oldIndex] beginAppearanceTransition:NO animated:NO];
    }
    if (newIndex >= 0 && newIndex < self.viewControllers.count) {
        [self.viewControllers[newIndex] beginAppearanceTransition:YES animated:NO];
    }
}

// newIndex已经出现 oldIndex已经消失
- (void)endAppearanceTransitionWithNewIndex:(NSInteger)newIndex oldIndex:(NSInteger)oldIndex {
    if (newIndex == oldIndex) { return; }
    if (!self.haveAppearancex) { return; }
    self.haveAppearancex = NO;
    if (oldIndex >= 0 && oldIndex < self.viewControllers.count) {
        self.lastAppearanceIndex = -1;
        [self.viewControllers[oldIndex] endAppearanceTransition];
    }
    if (newIndex >= 0 && newIndex < self.viewControllers.count) {
        [self.viewControllers[newIndex] endAppearanceTransition];
    }
}

// 懒加载指定视图
- (void)loadChildViewControllerAtIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.viewControllers.count) {
        return;
    }
    
    if ([self.childViewControllers containsObject:self.viewControllers[index]]) {
        return;
    }
    
    UIViewController *vc = self.viewControllers[index];
    vc.view.frame = CGRectMake(index * self.horizontalScrollView.bounds.size.width, 0, self.horizontalScrollView.bounds.size.width, self.horizontalScrollView.bounds.size.height);
    [self.horizontalScrollView addSubview:vc.view];
    [vc.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(index * self.horizontalScrollView.bounds.size.width);
        make.top.mas_equalTo(0);
        make.height.width.mas_equalTo(vc.view.superview);
    }];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    [self menuBarControllerDidLoadViewController:vc];
    
    // 添加观察者
    if ([vc isKindOfClass:[LCMenuBarController class]]) {
        // 处理PageScroll
        for (UIViewController *subVC in ((LCMenuBarController *)vc).viewControllers) {
            UIScrollView *scrollView = [self scrollViewFromViewController:subVC];
            if (scrollView && ![self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                [self.observerDictionary setValue:@(1) forKey:[NSString stringWithFormat:@"%p", scrollView]];
                [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            }
            scrollView.scrollsToTop = NO;
            scrollView.alwaysBounceVertical = YES;
            if ([self.observerDelegate respondsToSelector:@selector(menuBarAddObserver:)]) {
                [self.observerDelegate menuBarAddObserver:scrollView];
            }
        }
        ((LCMenuBarController *)vc).observerDelegate = self;
        ((LCMenuBarController *)vc).scrollsToTop = self.scrollsToTop;
    } else {
        UIScrollView *scrollView = [self scrollViewFromViewController:vc];
        if (scrollView && ![self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
            [self.observerDictionary setValue:@(1) forKey:[NSString stringWithFormat:@"%p", scrollView]];
            [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
        scrollView.scrollsToTop = NO;
        scrollView.alwaysBounceVertical = YES;
        if ([self.observerDelegate respondsToSelector:@selector(menuBarAddObserver:)]) {
            [self.observerDelegate menuBarAddObserver:scrollView];
        }
    }
    
    // 设置弹性状态
    if ([vc isKindOfClass:[LCMenuBarController class]]) {
        LCMenuBarController *menuBar = (LCMenuBarController *)vc;
        menuBar.verticalScrollView.alwaysBounceHorizontal = YES;
    }
    
}

// 控制器加载完成
- (void)menuBarControllerDidLoadViewController:(UIViewController *)vc {
    
}

// MARK: - 系统属性管理

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.currentViewController ?: super.childViewControllerForStatusBarStyle;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.currentViewController ?: super.childViewControllerForStatusBarStyle;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.currentViewController ?: super.childViewControllerForStatusBarStyle;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return self.currentViewController.modalPresentationStyle;
}

- (BOOL)shouldAutorotate {
    return self.currentViewController ? self.currentViewController.shouldAutorotate : super.shouldAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.currentViewController ? self.currentViewController.preferredInterfaceOrientationForPresentation : super.preferredInterfaceOrientationForPresentation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.currentViewController ? self.currentViewController.supportedInterfaceOrientations : super.supportedInterfaceOrientations;
}

// MARK: - 系统方法

- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers
{
    self = [super init];
    if (self) {
        _viewControllers = viewControllers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollsToTop = YES;
    _scrollAnimated = YES;
    
    _horizontalScrollView = [[LCMenuBarScrollView alloc] init];
    _horizontalScrollView.delegate = self;
    _horizontalScrollView.pagingEnabled = YES;
    _horizontalScrollView.scrollsToTop = NO;
    _horizontalScrollView.bounces = NO;
    
    _outsideCanScroll = YES;
    
    self.shouldNested = YES;
    
}

- (void)dealloc {
    // 移除观察者
    if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]]) {
        [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]];
        [_verticalScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    [self removeSubViewControllerObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
    
    if ([change[@"new"] CGPointValue].y == [change[@"old"] CGPointValue].y) {
        return;
    }
    
    if (![object isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    UIScrollView *scrollView = object;
    
    NSString *key = [NSString stringWithFormat:@"%p", scrollView];
    CGFloat oldOffset = [[self.offsetDictionary objectForKey:key] floatValue];
    [self.offsetDictionary setObject:[NSNumber numberWithFloat: scrollView.contentOffset.y] forKey:key];
    
    // 竖向滚动视图
    if (scrollView == self.verticalScrollView) {
        
        if (!self.currentViewController) {
            return;
        }
        
        // 竖向滚动视图滚动时不需要处理
        if (self.notHandleVerticalScrollView) {
            return;
        }
        
        UIViewController *vc = self.currentViewController;
        
        if (scrollView.contentOffset.y < oldOffset) {
            // 往下滑
            
            // 菜单可以拖拽
            if (self.menuCanDrag) {
                BOOL pointInSubView = NO;
                UIScrollView *subScrollView = [self scrollViewFromViewController:self.currentViewController];
                if (subScrollView) {
                    CGPoint point = [scrollView.panGestureRecognizer locationInView:subScrollView.superview];
                    if (point.y > CGRectGetMinY(subScrollView.frame) && point.y < CGRectGetMaxY(subScrollView.frame)) {
                        pointInSubView = YES;
                    }
                }
                // 不是拖拽头部且子视图有偏移时保持不动(拖拽菜单下滑不处理)
                if (pointInSubView && subScrollView.contentOffset.y > 0) {
                    [self.offsetDictionary setObject:[NSNumber numberWithFloat: oldOffset] forKey:key];
                    scrollView.contentOffset = CGPointMake(0, oldOffset);
                }
            } else {
                // 子视图滑到最顶部时竖向滚动视图可以滑动
                if (self.outsideCanScroll) {
                    
                    // header滑到顶部后下拉是否可固定时保持不动(点击状态栏的情况不处理)
                    if (self.headerCanFixed && !self.touchStatusBar) {
                        [self.offsetDictionary setObject:[NSNumber numberWithFloat: oldOffset] forKey:key];
                        scrollView.contentOffset = CGPointMake(0, oldOffset);
                    }
                    
                } else {
                    
                    // 判断子视图内容可否滑动
                    BOOL canScroll = NO;
                    if ([vc isKindOfClass:[LCMenuBarController class]]) {
                        UIViewController *subVC = [((LCMenuBarController *)vc).viewControllers objectAtIndex:((LCMenuBarController *)vc).currentIndex];
                        UIScrollView *subScrollView = [self scrollViewFromViewController:subVC];
                        if (subScrollView.contentSize.height > subScrollView.frame.size.height || subScrollView.contentOffset.y > 0) {
                            canScroll = YES;
                        }
                    } else {
                        UIScrollView *subScrollView = [self scrollViewFromViewController:vc];
                        if (subScrollView.contentSize.height > subScrollView.frame.size.height || subScrollView.contentOffset.y > 0) {
                            canScroll = YES;
                        }
                    }
                    // 子视图可以滑动时保持不动(点击状态栏的情况不处理)
                    if (canScroll && !self.touchStatusBar) {
                        [self.offsetDictionary setObject:[NSNumber numberWithFloat: oldOffset] forKey:key];
                        scrollView.contentOffset = CGPointMake(0, oldOffset);
                    }
                    
                }
            }
            
        } else {
            // 往上滑
            
            // 偏移量达到最大时不可滑动，子视图可以滑动
            if (scrollView.contentOffset.y >= self.verticalMaxOffset) {
                // 偏移量达到最大时保持不动
                [self.offsetDictionary setObject:[NSNumber numberWithFloat: self.verticalMaxOffset] forKey:key];
                scrollView.contentOffset = CGPointMake(0, self.verticalMaxOffset);
                self.insideCanScroll = YES;
                self.outsideCanScroll = NO;
            } else {
                self.insideCanScroll = NO;
            }
            
            // 没有弹性并且子视图偏移量小于0时保持不动
            if (!self.bounces) {
                if ([vc respondsToSelector:@selector(lcScrollView)]) {
                    UIScrollView *subScrollView = [self scrollViewFromViewController:vc];
                    if (subScrollView.contentOffset.y < 0) {
                        [self.offsetDictionary setObject:[NSNumber numberWithFloat: oldOffset] forKey:key];
                        scrollView.contentOffset = CGPointMake(0, oldOffset);
                    }
                }
            }
            
        }
        
        // 没有弹性并且偏移量小于0时保持不动
        if (!self.bounces && scrollView.contentOffset.y < 0) {
            [self.offsetDictionary setObject:[NSNumber numberWithFloat: 0] forKey:key];
            scrollView.contentOffset = CGPointZero;
        }
        
    } else { // 子视图
        
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidScroll:type:)]) {
            [self.delegate menuBarScrollViewDidScroll:scrollView type:LCMenuBarScrollViewTypeChild];
        }
        
        // 内部滚动视图滚动时不需要处理
        if (self.notHandleChildScrollView) {
            return;
        }
        
        // 竖向滚动视图不能滑动时不处理
        if (self.verticalScrollView && self.verticalScrollView.contentSize.height <= self.verticalScrollView.frame.size.height) {
            return;
        }
        
        if (scrollView.contentOffset.y < oldOffset) {
            // 往下滑
            
            // 子视图滑到最顶部时不可滑动，竖向滚动视图可以滑动
            if (scrollView.contentOffset.y < 0) {
                // 竖向滚动视图没有弹性并且偏移量为0时可以滑动
                if (self.bounces || (!self.bounces && self.verticalScrollView.contentOffset.y > 0)) {
                    // header可以固定时可以滑动
                    if (!self.headerCanFixed) {
                        if (scrollView.contentOffset.y != 0) {
                            [self.offsetDictionary setObject:[NSNumber numberWithFloat: 0] forKey:key];
                            scrollView.contentOffset = CGPointZero;
                        }
                    }
                }
                self.outsideCanScroll = YES;
                self.insideCanScroll = NO;
            } else {
                if (!self.touchStatusBar) {
                    self.outsideCanScroll = NO;
                }
            }
            
        } else {
            // 往上滑
            
            // 竖向滚动视图偏移量达到最大时子视图可以滑动
            if (!self.insideCanScroll && oldOffset >= 0 ) {
                // 竖向滚动视图没有弹性并且偏移量为0时可以滑动
                if (self.bounces || (!self.bounces && self.verticalScrollView.contentOffset.y > 0)) {
                    // header可以固定时可以滑动
                    if (!self.headerCanFixed) {
                        if (scrollView.contentOffset.y != oldOffset) {
                            [self.offsetDictionary setObject:[NSNumber numberWithFloat: oldOffset] forKey:key];
                            scrollView.contentOffset = CGPointMake(0, oldOffset);
                        }
                    }
                }
                if (oldOffset < 0 && scrollView.contentOffset.y > 0) {
                    oldOffset = 0;
                    if (scrollView.contentOffset.y != oldOffset) {
                        [self.offsetDictionary setObject:[NSNumber numberWithFloat: oldOffset] forKey:key];
                        scrollView.contentOffset = CGPointMake(0, oldOffset);
                    }
                }
            }
            
        }
        
    }
    
}

// MARK: - 自定义方法

// MARK: 移除控制器的观察者
- (void)removeSubViewControllerObserver {
    if (self.observerDictionary.count == 0 || (self.observerDictionary.count == 1 && [self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]])) {
        return;
    }
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[LCMenuBarController class]]) {
            // 处理PageScroll
            for (UIViewController *subVC in ((LCMenuBarController *)vc).viewControllers) {
                UIScrollView *scrollView = [self scrollViewFromViewController:subVC];
                if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                    [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", scrollView]];
                    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                }
            }
            UIScrollView *scrollView = ((LCMenuBarController *)vc).verticalScrollView;
            if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", scrollView]];
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            }
        } else {
            UIScrollView *scrollView = [self scrollViewFromViewController:vc];
            if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", scrollView]];
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            }
        }
    }
}

// MARK: 返回控制器里可以滑动的视图
- (UIScrollView *)scrollViewFromViewController:(UIViewController *)viewController {
    if (!viewController) {
        return nil;
    }
    if ([viewController conformsToProtocol:@protocol(LCMenuBarProtocol)]) {
        if ([viewController respondsToSelector:@selector(lcScrollView)]) {
            return [viewController performSelector:@selector(lcScrollView)];
        }
    }
    return nil;
}

// MARK: 返回菜单视图
- (UIView<LCMenuBarDelegate> *)menuBarFromView:(UIView *)view {
    if ([view conformsToProtocol:@protocol(LCMenuBarProtocol)]) {
        if ([view respondsToSelector:@selector(lcMenuBar)]) {
            view = [(UIView<LCMenuBarProtocol> *)view lcMenuBar];
        }
    }
    if ([view conformsToProtocol:@protocol(LCMenuBarDelegate)]) {
        if ([view respondsToSelector:@selector(menuBarDidSelect:atIndex:)]) {
            return (UIView<LCMenuBarDelegate> *)view;
        }
    }
    return nil;
}

// MARK: 竖向滚动视图回到顶部
- (void)scrollToTopWithAnimated:(BOOL)animated {
    if (self.verticalScrollView.contentOffset.y == 0) { return; }
    self.touchStatusBar = YES;
    self.outsideCanScroll = YES;
    self.verticalScrollView.isTouching = YES;
    [self.verticalScrollView setContentOffset:CGPointZero animated:animated];
}

// MARK: 子视图回到顶部
- (void)subScrollViewScrollToTopWithAnimated:(BOOL)animated {
    if ([self.currentViewController isKindOfClass:[LCMenuBarController class]]) {
        self.outsideCanScroll = YES;
        self.verticalScrollView.isTouching = YES;
        [(LCMenuBarController *)self.currentViewController scrollToTopWithAnimated:YES];
        [(LCMenuBarController *)self.currentViewController subScrollViewScrollToTopWithAnimated:YES];
    } else {
        UIScrollView *scrollView = [self scrollViewFromViewController:self.currentViewController];
        if (scrollView.contentOffset.y == 0) { return; }
        self.outsideCanScroll = YES;
        self.verticalScrollView.isTouching = YES;
        [scrollView setContentOffset:CGPointZero animated:animated];
    }
}

// MARK: 滑动到指定位置
- (void)scrollToIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    [self loadChildViewControllerAtIndex:currentIndex];
    [self.horizontalScrollView setContentOffset:CGPointMake(currentIndex * self.horizontalScrollView.bounds.size.width, 0) animated:animated];
    [self appearanceTransitionWithNewIndex:currentIndex oldIndex:_currentIndex];
    self.currentIndex = currentIndex;
}

// MARK: 菜单选中事件
- (void)menuBarWillChangeAtIndex:(NSInteger)currentIndex {
    if ([self menuBarShouldChangeAtIndex:currentIndex]) {
        [self menuBarDidChangedAtIndex:currentIndex];
    }
}

// MARK: 菜单是否需要选中 默认返回YES 返回NO则滑动子视图时菜单不会有选中态
- (BOOL)menuBarShouldChangeAtIndex:(NSInteger)currentIndex {
    return YES;
}

// MARK: 菜单已经选中
- (void)menuBarDidChangedAtIndex:(NSInteger)currentIndex {
    UIView<LCMenuBarDelegate> *menuBar = [self menuBarFromView:self.menuBar];
    [menuBar menuBarDidSelect:menuBar atIndex:currentIndex];
    menuBar = [self menuBarFromView:self.headerView];
    [menuBar menuBarDidSelect:menuBar atIndex:currentIndex];
    menuBar = [self menuBarFromView:self.footerView];
    [menuBar menuBarDidSelect:menuBar atIndex:currentIndex];
}

// MARK: - 代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.verticalScrollView) {
        
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidScroll:type:)]) {
            [self.delegate menuBarScrollViewDidScroll:scrollView type:LCMenuBarScrollViewTypeVertical];
        }
        
    } else if (scrollView == self.horizontalScrollView) {
        
        if (self.horizontalScrollView.isDragging) {
            // 懒加载
            NSInteger i = [scrollView.panGestureRecognizer translationInView:scrollView].x < 0 ? 1 : 0;
            [self loadChildViewControllerAtIndex:(scrollView.contentOffset.x - 1) / scrollView.bounds.size.width + i];
            NSInteger currentIndex = (scrollView.contentOffset.x + scrollView.bounds.size.width / 2) / scrollView.bounds.size.width;
            if (self.currentIndex != currentIndex) {
                [self beginAppearanceTransitionWithNewIndex:currentIndex oldIndex:self.currentIndex];
                self.currentIndex = currentIndex;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidScroll:type:)]) {
            [self.delegate menuBarScrollViewDidScroll:scrollView type:LCMenuBarScrollViewTypeHorizontal];
        }
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.verticalScrollView) {
        self.alwaysBounceHorizontal = self.verticalScrollView.alwaysBounceHorizontal;
        if (self.verticalScrollView.alwaysBounceHorizontal) {
            self.verticalScrollView.alwaysBounceHorizontal = NO;
        }
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewWillBeginDragging:type:)]) {
            [self.delegate menuBarScrollViewWillBeginDragging:scrollView type:LCMenuBarScrollViewTypeVertical];
        }
    } else if (scrollView == self.horizontalScrollView) {
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewWillBeginDragging:type:)]) {
            [self.delegate menuBarScrollViewWillBeginDragging:scrollView type:LCMenuBarScrollViewTypeHorizontal];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.verticalScrollView) {
        if (self.alwaysBounceHorizontal) {
            self.verticalScrollView.alwaysBounceHorizontal = YES;
        }
        if (!decelerate) {
            self.verticalScrollView.isTouching = NO;
        }
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidEndDragging:willDecelerate:type:)]) {
            [self.delegate menuBarScrollViewDidEndDragging:scrollView willDecelerate:decelerate type:LCMenuBarScrollViewTypeVertical];
        }
    } else if (scrollView == self.horizontalScrollView) {
        if (!decelerate) {
            self.horizontalScrollView.isTouching = NO;
            [self endAppearanceTransitionWithNewIndex:self.currentIndex oldIndex:self.lastAppearanceIndex];
        }
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidEndDragging:willDecelerate:type:)]) {
            [self.delegate menuBarScrollViewDidEndDragging:scrollView willDecelerate:decelerate type:LCMenuBarScrollViewTypeHorizontal];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.verticalScrollView) {
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewWillBeginDecelerating:type:)]) {
            [self.delegate menuBarScrollViewWillBeginDecelerating:scrollView type:LCMenuBarScrollViewTypeVertical];
        }
    } else if (scrollView == self.horizontalScrollView) {
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewWillBeginDecelerating:type:)]) {
            [self.delegate menuBarScrollViewWillBeginDecelerating:scrollView type:LCMenuBarScrollViewTypeHorizontal];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.verticalScrollView) {
        self.verticalScrollView.isTouching = NO;
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidEndDecelerating:type:)]) {
            [self.delegate menuBarScrollViewDidEndDecelerating:scrollView type:LCMenuBarScrollViewTypeVertical];
        }
    } else if (scrollView == self.horizontalScrollView) {
        [self endAppearanceTransitionWithNewIndex:self.currentIndex oldIndex:self.lastAppearanceIndex];
        if ([self.delegate respondsToSelector:@selector(menuBarScrollViewDidEndDecelerating:type:)]) {
            [self.delegate menuBarScrollViewDidEndDecelerating:scrollView type:LCMenuBarScrollViewTypeHorizontal];
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if (self.touchStatusBar) { return NO; }
    self.touchStatusBar = YES;
    [self subScrollViewScrollToTopWithAnimated:YES];
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    self.touchStatusBar = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.touchStatusBar = NO;
}

// MARK: 实现菜单代理

- (void)menuBarDidSelect:(UIView<LCMenuBarDelegate> *)menuBar atIndex:(NSInteger)currentIndex {
    [self scrollToIndex:currentIndex animated:self.scrollAnimated];
}

// MARK: 实现观察者代理

- (void)menuBarAddObserver:(UIScrollView *)scrollView {
    if (![self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
        [self.observerDictionary setValue:@(1) forKey:[NSString stringWithFormat:@"%p", scrollView]];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    if ([self.observerDelegate respondsToSelector:@selector(menuBarAddObserver:)]) {
        [self.observerDelegate menuBarAddObserver:scrollView];
    }
}

// MARK: 实现手势代理

- (BOOL)menuBarGestureShouldRecognizeSimultaneously:(UIResponder *)responder {
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:LCMenuBarController.class]) {
            for (UIViewController *subVC in ((LCMenuBarController *)vc).viewControllers) {
                if (responder == [self scrollViewFromViewController:subVC]) {
                    return YES;
                }
            }
        } else {
            if (responder == [self scrollViewFromViewController:vc]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
