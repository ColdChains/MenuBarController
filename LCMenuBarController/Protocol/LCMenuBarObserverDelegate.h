//
//  LCMenuBarControllerObserverDelegate.h
//  LCMenuBarController
//
//  Created by lax on 2021/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LCMenuBarObserverDelegate <NSObject>

// 添加观察者回调
- (void)menuBarAddObserver:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
