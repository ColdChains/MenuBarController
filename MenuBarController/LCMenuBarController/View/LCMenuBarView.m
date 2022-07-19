//
//  LCMenuBarView.m
//  MenuBarController
//
//  Created by lax on 2021/9/16.
//

#import "LCMenuBarView.h"
#import "LCMenuBarProtocol.h"
#import <Masonry/Masonry.h>

@interface LCMenuBarView () <LCMenuBarGestureDelegate>

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

// 弹性管理 记录竖向滚动视图是否有弹性
@property (nonatomic) BOOL alwaysBounceHorizontal;

@end

@implementation LCMenuBarView

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
        [self scrollViewFromView:self.currentView].scrollsToTop = NO;
    }
    
    _currentIndex = currentIndex;
    
    // 竖向滚动视图不能滚动时 动态设置当前显示控制器的scrollsToTop
    if (self.verticalScrollView.contentSize.height <= self.verticalScrollView.frame.size.height && self.scrollsToTop) {
        [self scrollViewFromView:self.currentView].scrollsToTop = YES;
    }
    
    [self menuBarWillChangeAtIndex:currentIndex];
    
}

- (UIView *)currentView {
    if (self.currentIndex >= 0 && self.currentIndex < self.views.count) {
        return self.views[self.currentIndex];
    }
    return nil;
}

- (UIScrollView *)currentScrollView {
    return [self scrollViewFromView:self.currentView];
}

- (CGFloat)verticalMaxOffset {
    return _headerView ? (_headerView.frame.size.height + _headerBottomMargin - _headerScrollTopMargin) : 0;
}


- (void)setShouldNested:(BOOL)shouldNested {
    _shouldNested = shouldNested;
    
    if (shouldNested) {
        if (!_verticalScrollView) {
            _verticalScrollView = [[LCMenuBarScrollView alloc] init];
            _verticalScrollView.delegate = self;
            _verticalScrollView.gestureDelegate = self;
            _verticalScrollView.shouldRecognizeSimultaneously = YES;
            [self addSubview:_verticalScrollView];
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
    
    [self.verticalScrollView ?: self addSubview:self.horizontalScrollView];
    [self.horizontalScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(self.horizontalScrollView.superview);
        make.height.mas_equalTo(self.horizontalScrollView.superview);
    }];
    if (self.headerView) {
        [self.headerView removeFromSuperview];
        [self.verticalScrollView ?: self addSubview:self.headerView];
        [self layoutHeaderView];
    }
    if (self.menuBar) {
        [self.headerView removeFromSuperview];
        [self.verticalScrollView ?: self addSubview:self.menuBar];
        [self layoutMenuBar];
    }
    if (self.footerView) {
        [self.headerView removeFromSuperview];
        [self.verticalScrollView ?: self addSubview:self.footerView];
        [self layoutFooterView];
    }
    [self layoutHorizontalScrollView];
    
    if (self.views) {
        self.views = _views;
    }
    
}

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    _scrollsToTop = scrollsToTop;
    self.verticalScrollView.scrollsToTop = scrollsToTop;
}

- (void)setTopMargin:(CGFloat)topMargin {
    _topMargin = topMargin;
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
    [self layoutHorizontalScrollViewHeight];
}

- (void)setHeaderBottomMargin:(CGFloat)headerBottomMargin {
    _headerBottomMargin = headerBottomMargin;
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
    if (!self.menuBar) { return; }
    [self layoutHorizontalScrollView];
}

- (void)setHeaderAutoHeight:(BOOL)headerAutoHeight {
    _headerAutoHeight = headerAutoHeight;
    [self layoutHeaderView];
}

- (void)setMenuAutoHeight:(BOOL)menuAutoHeight {
    _menuAutoHeight = menuAutoHeight;
    [self layoutMenuBar];
}

- (void)setFooterAutoHeight:(BOOL)footerAutoHeight {
    _footerAutoHeight = footerAutoHeight;
    [self layoutFooterView];
}

- (void)setHeaderView:(UIView *)headerView {
    [_headerView removeFromSuperview];
    _headerView = headerView;
    if (headerView) {
        [self.verticalScrollView ?: self addSubview:headerView];
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
    [self.verticalScrollView ?: self addSubview:menuBar];
    [self layoutMenuBar];
    [self layoutHorizontalScrollView];
}

- (void)setFooterView:(UIView *)footerView {
    [_footerView removeFromSuperview];
    _footerView = footerView;
    if (!footerView) { return; }
    [self addSubview:footerView];
    [self layoutFooterView];
    [self layoutVerticalScrollView];
}

- (void)setViews:(NSArray<UIView *> *)views {
    
    [self removeSubViewObserver];
    for (UIView *view in _views) {
        [view removeFromSuperview];
    }
    
    _views = views;
    if (!self.horizontalScrollView) { return; }
    if (views.count == 0) { return; }
    
    for (int i = 0; i < views.count; i++) {
        
        UIView *subView = views[i];
        
        [self.horizontalScrollView addSubview:subView];
        [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.mas_equalTo(self.horizontalScrollView ?: self);
            } else if (i == views.count - 1) {
                make.left.mas_equalTo(views[i - 1].mas_right);
                make.right.mas_equalTo(self.horizontalScrollView ?: self);
            } else {
                make.left.mas_equalTo(views[i - 1].mas_right);
            }
            make.top.bottom.equalTo(self.horizontalScrollView ?: self);
            make.width.mas_equalTo(self.horizontalScrollView ?: self);
            make.height.mas_equalTo(self.horizontalScrollView ?: self);
        }];
        
        // 添加观察者
        if ([subView isKindOfClass:[LCMenuBarView class]]) {
            // 处理PageView
            for (UIView *view in ((LCMenuBarView *)subView).views) {
                UIScrollView *scrollView = [self scrollViewFromView:view];
                if (scrollView && ![self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                    [self.observerDictionary setValue:@(1) forKey:[NSString stringWithFormat:@"%p", scrollView]];
                    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                }
                scrollView.scrollsToTop = NO;
                scrollView.alwaysBounceVertical = YES;
            }
            ((LCMenuBarView *)subView).scrollsToTop = self.scrollsToTop;
        } else {
            UIScrollView *scrollView = [self scrollViewFromView:subView];
            if (scrollView && ![self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                [self.observerDictionary setValue:@(1) forKey:[NSString stringWithFormat:@"%p", scrollView]];
                [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            }
            scrollView.scrollsToTop = NO;
            scrollView.alwaysBounceVertical = YES;
        }
    }
    
    // 设置弹性状态
    for (UIView *view in views) {
        if ([view isKindOfClass:[LCMenuBarView class]]) {
            LCMenuBarView *menuBar = (LCMenuBarView *)view;
            menuBar.verticalScrollView.alwaysBounceHorizontal = YES;
        }
    }
    
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

// MARK: - 系统方法

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _scrollsToTop = YES;
        _scrollAnimated = YES;
        
        _horizontalScrollView = [[LCMenuBarScrollView alloc] init];
        _horizontalScrollView.delegate = self;
        _horizontalScrollView.pagingEnabled = YES;
        _horizontalScrollView.scrollsToTop = NO;
        
        _outsideCanScroll = YES;
        
        self.shouldNested = YES;
        
    }
    return self;
}

- (void)dealloc {
    // 移除观察者
    if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]]) {
        [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]];
        [_verticalScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    [self removeSubViewObserver];
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
        
        if (!self.currentView) {
            return;
        }
        
        // 竖向滚动视图滚动时不需要处理
        if (self.notHandleVerticalScrollView) {
            return;
        }
        
        UIView *view = self.currentView;
        
        if (scrollView.contentOffset.y < oldOffset) {
            // 往下滑
            
            // 菜单可以拖拽
            if (self.menuCanDrag) {
                BOOL pointInSubView = NO;
                UIScrollView *subScrollView = [self scrollViewFromView:view];
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
                    if ([view isKindOfClass:[LCMenuBarView class]]) {
                        UIView *subView = [((LCMenuBarView *)view).views objectAtIndex:((LCMenuBarView *)view).currentIndex];
                        UIScrollView *subScrollView = [self scrollViewFromView:subView];
                        if (subScrollView.contentSize.height > subScrollView.frame.size.height || subScrollView.contentOffset.y > 0) {
                            canScroll = YES;
                        }
                    } else {
                        UIScrollView *subScrollView = [self scrollViewFromView:view];
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
                if ([view respondsToSelector:@selector(lcScrollView)]) {
                    UIScrollView *subScrollView = [self scrollViewFromView:view];
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
- (void)removeSubViewObserver {
    if (self.observerDictionary.count == 0 || (self.observerDictionary.count == 1 && [self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", _verticalScrollView]])) {
        return;
    }
    for (UIView *subView in self.views) {
        if ([subView isKindOfClass:[LCMenuBarView class]]) {
            // 处理PageView
            for (UIView *view in ((LCMenuBarView *)subView).views) {
                UIScrollView *scrollView = [self scrollViewFromView:view];
                if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                    [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", scrollView]];
                    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                }
            }
        } else {
            UIScrollView *scrollView = [self scrollViewFromView:subView];
            if ([self.observerDictionary objectForKey:[NSString stringWithFormat:@"%p", scrollView]]) {
                [self.observerDictionary removeObjectForKey:[NSString stringWithFormat:@"%p", scrollView]];
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            }
        }
    }
}

// MARK: 返回视图里可以滑动的视图
- (UIScrollView *)scrollViewFromView:(UIView *)view {
    if (!view) {
        return nil;
    }
    if ([view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)view;
    } else {
        if ([view conformsToProtocol:@protocol(LCMenuBarProtocol)]) {
            if ([view respondsToSelector:@selector(lcScrollView)]) {
                return [view performSelector:@selector(lcScrollView)];
            }
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
    if ([self.currentView isKindOfClass:[LCMenuBarView class]]) {
        self.outsideCanScroll = YES;
        self.verticalScrollView.isTouching = YES;
        [(LCMenuBarView *)self.currentView scrollToTopWithAnimated:YES];
        [(LCMenuBarView *)self.currentView subScrollViewScrollToTopWithAnimated:YES];
    } else {
        UIScrollView *scrollView = [self scrollViewFromView:self.currentView];
        if (scrollView.contentOffset.y == 0) { return; }
        self.outsideCanScroll = YES;
        self.verticalScrollView.isTouching = YES;
        [scrollView setContentOffset:CGPointZero animated:animated];
    }
}

// MARK: 滑动到指定位置
- (void)scrollToIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    [self.horizontalScrollView setContentOffset:CGPointMake(currentIndex * self.horizontalScrollView.bounds.size.width, 0) animated:animated];
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
            NSInteger currentIndex = (scrollView.contentOffset.x + scrollView.bounds.size.width / 2) / scrollView.bounds.size.width;
            if (self.currentIndex != currentIndex) {
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

// MARK: 实现手势代理

- (BOOL)menuBarGestureShouldRecognizeSimultaneously:(UIResponder *)responder {
    for (UIView *view in self.views) {
        if ([view isKindOfClass:LCMenuBarView.class]) {
            for (UIView *subView in ((LCMenuBarView *)view).views) {
                if (responder == [self scrollViewFromView:subView]) {
                    return YES;
                }
            }
        } else {
            if (responder == [self scrollViewFromView:view]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
