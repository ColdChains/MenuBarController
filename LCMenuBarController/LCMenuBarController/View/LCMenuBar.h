//
//  LCMenuBar.h
//  LCMenuBarController
//
//  Created by lax on 2021/8/23.
//

#import <UIKit/UIKit.h>
#import "LCMenuBarDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LCMenuBarStyle) {
    LCMenuBarStyleFixed, // 宽度固定
    LCMenuBarStyleScroll, // 宽度自适应 可左右滑动
};

@interface LCMenuBar : UIScrollView <LCMenuBarDelegate>

// 样式
@property (nonatomic, readonly) LCMenuBarStyle style;

// 数据源
@property (nonatomic, copy) NSArray<NSString *> *dataArray;

// 当前下标
@property (nonatomic) NSInteger currentIndex;

// 内边距 默认0
@property (nonatomic) UIEdgeInsets edgeInsets;

// 菜单间距(Scroll样式生效) 默认24
@property (nonatomic) CGFloat itemMargin;

// 选中项在边缘是否自动调整位置(Scroll样式生效) 默认NO
@property (nonatomic) BOOL autoPosition;

// 未选中文字颜色 默认lightGrayColor
@property (nonatomic, strong) UIColor *textColor;

// 选中文字颜色 默认darkTextColor
@property (nonatomic, strong) UIColor *selectTextColor;

// 未选中文字大小 默认14
@property (nonatomic, strong) UIFont *textFont;

// 选中文字大小 默认14
@property (nonatomic, strong) UIFont *selectTextFont;

// 是否显示下划线 默认NO
@property (nonatomic) BOOL showLineView;

// 下划线宽度跟随文字 默认YES
@property (nonatomic) BOOL lineViewAutoWidth;

// 下划线与文字对齐方式 默认居中
@property (nonatomic) LCMenuBarLineAlignment lineViewAlignment;

// 下划线的宽度 默认16
@property (nonatomic) CGFloat lineViewWidth;

// 下划线的高度 默认2
@property (nonatomic) CGFloat lineViewHeight;

// 下划线的底部间距 默认1
@property (nonatomic) CGFloat lineViewBottom;

// 下划线的圆角 默认0
@property (nonatomic) CGFloat lineViewCornerRadius;

// 下划线的颜色 默认F8F8F8
@property (nonatomic, strong) UIColor *lineViewColor;

// 下划线 若自定义View则lineViewAutoWidth自动置为NO、lineViewColor自动置为clearColor
@property (nonatomic, strong) UIView *lineView;

/// 构造方法(使用frame布局)
/// @param frame 位置
/// @param style 样式
- (instancetype)initWithFrame:(CGRect)frame style:(LCMenuBarStyle)style;

@end

NS_ASSUME_NONNULL_END
