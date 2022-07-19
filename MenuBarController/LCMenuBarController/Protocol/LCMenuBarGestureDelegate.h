//
//  LCMenuBarGestureDelegate.h
//  MenuBarController
//
//  Created by lax on 2021/12/22.
//

NS_ASSUME_NONNULL_BEGIN

@protocol LCMenuBarGestureDelegate <NSObject>

// 判断是否同时响应该视图的手势
- (BOOL)menuBarGestureShouldRecognizeSimultaneously:(UIResponder *)responder;

@end

NS_ASSUME_NONNULL_END
