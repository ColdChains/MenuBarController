//
//  LCMenuBar.m
//  LCMenuBarController
//
//  Created by lax on 2021/8/23.
//

#import "LCMenuBar.h"

@interface LCMenuBar ()

// 样式
@property (nonatomic) LCMenuBarStyle style;

// 按钮数组
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArray;

@end

@implementation LCMenuBar

- (void)setDataArray:(NSArray<NSString *> *)dataArray {
    _dataArray = dataArray;
    [self initView];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex >= 0 && _currentIndex < self.buttonArray.count) {
        self.buttonArray[_currentIndex].titleLabel.font = self.textFont;
        [self.buttonArray[_currentIndex] setTitleColor:self.textColor forState:UIControlStateNormal];
    }
    
    NSInteger oldIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    if (_currentIndex >= 0 && _currentIndex < self.buttonArray.count) {
        self.buttonArray[_currentIndex].titleLabel.font = self.selectTextFont;
        [self.buttonArray[_currentIndex] setTitleColor:self.selectTextColor forState:UIControlStateNormal];
        [self initLineViewFrame];
    }
    
    if (oldIndex != currentIndex) {
        self.autoPosition = _autoPosition;
    }
}

- (void)setItemMargin:(CGFloat)itemeMargin {
    _itemMargin = itemeMargin;
    [self initView];
}

- (void)setAutoPosition:(BOOL)autoPosition {
    _autoPosition = autoPosition;
    if (autoPosition) {
        [UIView animateWithDuration:0.25 animations:^{
            [self checkPosition];
        }];
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self initView];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (UIButton *button in self.buttonArray) {
        [button setTitleColor:textColor forState:UIControlStateNormal];
    }
    [self.buttonArray[self.currentIndex] setTitleColor:self.selectTextColor forState:UIControlStateNormal];
}

- (void)setSelectTextColor:(UIColor *)selectTextColor {
    _selectTextColor = selectTextColor;
    [self.buttonArray[self.currentIndex] setTitleColor:selectTextColor forState:UIControlStateNormal];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    for (UIButton *button in self.buttonArray) {
        button.titleLabel.font = textFont;
    }
    self.buttonArray[self.currentIndex].titleLabel.font = self.selectTextFont;
    [self initLineViewFrame];
}

- (void)setSelectTextFont:(UIFont *)selectTextFont {
    _selectTextFont = selectTextFont;
    self.buttonArray[self.currentIndex].titleLabel.font = selectTextFont;
}

- (void)setShowLineView:(BOOL)isShowLineView {
    _showLineView = isShowLineView;
    _lineView.hidden = !isShowLineView;
    [self initLineViewFrame];
}

- (void)setLineViewAutoWidth:(BOOL)lineViewAutoWidth {
    _lineViewAutoWidth = lineViewAutoWidth;
    [self initLineViewFrame];
}

- (void)setLineViewAlignment:(LCMenuBarLineAlignment)lineViewAlignment {
    _lineViewAlignment = lineViewAlignment;
    [self initLineViewFrame];
}

- (void)setLineViewWidth:(CGFloat)lineViewWidth {
    _lineViewWidth = lineViewWidth;
    [self initLineViewFrame];
}

- (void)setLineViewHeight:(CGFloat)lineViewHeight {
    _lineViewHeight = lineViewHeight;
    [self initLineViewFrame];
}

- (void)setLineViewBottom:(CGFloat)lineViewBottom {
    _lineViewBottom = lineViewBottom;
    [self initLineViewFrame];
}

- (void)setLineViewCornerRadius:(CGFloat)lineViewCornerRadius {
    _lineViewCornerRadius = lineViewCornerRadius;
    _lineView.layer.cornerRadius = _lineViewCornerRadius;
}

- (void)setLineViewColor:(UIColor *)lineViewColor {
    _lineViewColor = lineViewColor;
    _lineView.backgroundColor = lineViewColor;
}

- (void)setLineView:(UIView *)lineView {
    [_lineView removeFromSuperview];
    _lineView = lineView;
    _lineViewWidth = lineView.frame.size.width;
    _lineViewHeight = lineView.frame.size.height;
    _lineViewCornerRadius = lineView.layer.cornerRadius;
    _lineViewColor = [UIColor clearColor];
    _lineViewAutoWidth = NO;
    _lineView.hidden = !self.showLineView;
    [self addSubview:lineView];
    [self sendSubviewToBack:lineView];
    [self initLineViewFrame];
}

- (instancetype)initWithFrame:(CGRect)frame style:(LCMenuBarStyle)style {
    self = [self initWithFrame:frame];
    if (self) {
        _style = style;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = YES;
        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _currentIndex = 0;
        _itemMargin = 24;
        _textColor = [UIColor lightGrayColor];
        _selectTextColor = [UIColor darkTextColor];
        _textFont = [UIFont systemFontOfSize:14];
        _selectTextFont = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        _lineViewWidth = 16;
        _lineViewHeight = 2;
        _lineViewCornerRadius = 1;
        _lineViewBottom = 1;
        _lineViewColor = [UIColor darkTextColor];
        _lineViewAutoWidth = YES;
    }
    return self;
}

- (void)initView {
    for (UIView *view in self.buttonArray) {
        [view removeFromSuperview];
    }
    if (self.dataArray.count > 0) {
        if (self.style == LCMenuBarStyleFixed) {
            [self layoutWithFixedStyle];
        } else {
            [self layoutWithScrollStyle];
        }
    }
    [self initLineViewFrame];
}

- (void)layoutWithFixedStyle {
    
    CGFloat x = self.edgeInsets.left;
    CGFloat w = self.frame.size.width / self.dataArray.count;
    CGFloat h = self.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
    
    self.buttonArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < self.dataArray.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = 100 + i;
        button.titleLabel.font = self.textFont;
        [button setTitle:self.dataArray[i] forState:UIControlStateNormal];
        [button setTitleColor:self.textColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonArray addObject:button];
        
        button.frame = CGRectMake(x, self.edgeInsets.top, w, h);
        x += w;
    }
    x += self.edgeInsets.right;
    
    self.contentSize = CGSizeMake(x, self.bounds.size.height);
    
}

- (void)layoutWithScrollStyle {
    
    CGFloat x = self.edgeInsets.left - self.itemMargin / 2;
    CGFloat w;
    CGFloat h = self.bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom;
    
    self.buttonArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < self.dataArray.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = 100 + i;
        button.titleLabel.font = self.textFont;
        [button setTitle:self.dataArray[i] forState:UIControlStateNormal];
        [button setTitleColor:self.textColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonArray addObject:button];
        
        w = [self getWidthWithIndex:i];
        button.frame = CGRectMake(x, self.edgeInsets.top, w + self.itemMargin, h);
        x += w + self.itemMargin;
    }
    x += self.edgeInsets.right - self.itemMargin / 2;
    
    self.contentSize = CGSizeMake(x, self.bounds.size.height);
    
}

// 获取文字的宽度
- (CGFloat)getWidthWithIndex:(NSInteger)index {
    CGSize maxSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    NSDictionary *dic = @{NSFontAttributeName : self.buttonArray[index].titleLabel.font};
    CGSize size = [self.dataArray[index] boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return ceil(size.width);
}

// 设置下划线的位置
- (void)initLineViewFrame {
    if (self.dataArray.count == 0) {
        _lineView.frame = CGRectZero;
        return;
    }
    if (self.showLineView == NO || self.currentIndex < 0 || self.currentIndex >= self.buttonArray.count) {
        return;
    }
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.layer.cornerRadius = self.lineViewCornerRadius;
        _lineView.backgroundColor = self.lineViewColor;
        [self addSubview:_lineView];
        [self sendSubviewToBack:_lineView];
    }
    CGFloat w;
    if (self.lineViewAutoWidth == YES) {
        w = [self getWidthWithIndex:self.currentIndex];
    } else {
        w = self.lineViewWidth;
    }
    CGFloat x = self.buttonArray[self.currentIndex].center.x - w / 2;
    if (self.lineViewAutoWidth == NO && self.lineViewAlignment != LCMenuBarLineAlignmentCenter) {
        x += self.lineViewAlignment * ([self getWidthWithIndex:self.currentIndex] - self.lineViewWidth) / 2;
    }
    self.lineView.frame = CGRectMake(x, self.frame.size.height - self.edgeInsets.bottom - self.lineViewHeight - self.lineViewBottom, w, self.lineViewHeight);
}

// 检查当前选中的按钮是否到边缘
- (void)checkPosition {
    if (self.contentSize.width <= self.frame.size.width) {
        return;
    }
    CGRect frame = _buttonArray[_currentIndex].frame;
    CGRect rect = [self convertRect:frame toView:self.superview];
    CGFloat margin = 60;
    
    if (rect.origin.x < margin && self.contentOffset.x > 0) {
        CGFloat x = frame.origin.x - margin;
        [self setContentOffset:CGPointMake(x > 0 ? x : 0, 0) animated:YES];
    }
    if (rect.origin.x + rect.size.width > self.bounds.size.width - margin && self.contentOffset.x < self.contentSize.width) {
        CGFloat x = frame.origin.x - (self.bounds.size.width - margin - frame.size.width);
        [self setContentOffset:CGPointMake(x < self.contentSize.width - self.bounds.size.width ? x : self.contentSize.width - self.bounds.size.width, 0) animated:YES];
    }
}

// 按钮点击事件
- (void)buttonAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(menuBarDidSelect:atIndex:)]) {
        [((id<LCMenuBarDelegate>)self.delegate) menuBarDidSelect:self atIndex:sender.tag - 100];
    }
}

// MARK: 实现菜单代理
- (void)menuBarDidSelect:(UIView<LCMenuBarDelegate> *)menuBar atIndex:(NSInteger)currentIndex {
    self.currentIndex = currentIndex;
}

@end
