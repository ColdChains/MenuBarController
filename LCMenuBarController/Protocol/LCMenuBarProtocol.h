//
//  LCMenuBarProtocol.h
//  LCMenuBarController
//
//  Created by lax on 2021/12/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LCMenuBarDelegate;

@protocol LCMenuBarProtocol <NSObject>

@optional

// 返回可以滚动的视图
- (nullable UIScrollView *)lcScrollView;

// 返回菜单视图
- (nullable UIView<LCMenuBarDelegate> *)lcMenuBar;

@end

NS_ASSUME_NONNULL_END

