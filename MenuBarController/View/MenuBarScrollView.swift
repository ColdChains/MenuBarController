//
//  MenuBarScrollView.swift
//  MenuBarController
//
//  Created by lax on 2022/9/14.
//

import UIKit

public protocol MenuBarScrollViewDelegate: NSObjectProtocol {
    
    /// 正在滚动
    func menuBarScrollViewDidScroll(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType)
    
    /// 开始拖拽
    func menuBarScrollViewWillBeginDragging(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType)

    /// 停止拖拽
    func menuBarScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool, type: MenuBarScrollView.ViewType)

    /// 开始滚动
    func menuBarScrollViewWillBeginDecelerating(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType)

    /// 停止滚动
    func menuBarScrollViewDidEndDecelerating(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType)
    
}

extension MenuBarScrollViewDelegate {
    
    func menuBarScrollViewDidScroll(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType) {}
    
    func menuBarScrollViewWillBeginDragging(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType) {}

    func menuBarScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool, type: MenuBarScrollView.ViewType) {}

    func menuBarScrollViewWillBeginDecelerating(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType) {}

    func menuBarScrollViewDidEndDecelerating(_ scrollView: UIScrollView, type: MenuBarScrollView.ViewType) {}
    
}

protocol MenuBarScrollViewGestureDelegate: NSObjectProtocol {
    
    /// 判断是否同时响应该视图的手势
    func menuBarScrollView(_ menuBarScrollView: MenuBarScrollView, gestureShouldRecognizeSimultaneouslyWith responder: UIResponder) -> Bool
    
}

open class MenuBarScrollView: UIScrollView {
    
    public enum ViewType {
        /// 竖向滚动视图
        case vertical
        /// 横向滚动视图
        case horizontal
        /// 菜单滚动视图
        case menu
        /// 内部滚动视图
        case child
    }
    
    weak var gestureDelegate: MenuBarScrollViewGestureDelegate?
    
    /// 是否允许手势传递 默认NO
    open var shouldRecognizeSimultaneously = false

    /// 手指是否正在按住不可滑动的区域
    open var isTouching = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        delaysContentTouches = false
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isTouching = true
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isTouching = false
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    /// 拖拽按钮时不调用touchesBegan 在这里设置isTouching
    open override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        if isInMenuBar(view) {
            isTouching = true
        }
        return true
    }
    
    /// 避免拖拽菜单时事件被拦截不滚动
    open override func touchesShouldCancel(in view: UIView) -> Bool {
        super.touchesShouldCancel(in: view)
        return true
    }

    /// 判断视图是否在菜单内
    private func isInMenuBar(_ view: UIView?) -> Bool {
        var targetView = view
        while let _ = targetView {
            if !(targetView is MenuBarView) && targetView is MenuBarDelegate {
                return true
            }
            targetView = targetView?.superview
        }
//        if !(view is MenuBarView) && view is MenuBarDelegate {
//            return true
//        } else {
//            var targetView = view
//            while let _ = targetView?.superview {
//                targetView = targetView?.superview
//                if !(targetView is MenuBarView) && targetView is MenuBarDelegate {
//                    return true
//                }
//            }
//        }
        return false
    }

}

extension MenuBarScrollView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 两个都是竖向滚动视图时返回YES
        guard let responder = otherGestureRecognizer.view else { return false }
        if let responder = responder as? MenuBarScrollView {
            return shouldRecognizeSimultaneously && responder.shouldRecognizeSimultaneously
        }
        // 根据代理判断responder是否是联动的ScrollView
        return gestureDelegate?.menuBarScrollView(self, gestureShouldRecognizeSimultaneouslyWith: responder) ?? false
    }
    
}
