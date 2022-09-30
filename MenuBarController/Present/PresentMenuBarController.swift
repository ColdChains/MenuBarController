//
//  PresentMenuBarController.swift
//  MenuBarController
//
//  Created by lax on 2022/9/22.
//

import UIKit

extension PresentMenuBarController {
    
    public enum ContentHeight {
        case min
        case middle
        case max
    }
    
    public enum DecelerationRate: CGFloat {
        case min = 0
        case slow = 0.08
        case normal = 0.12
        case fast = 0.2
        case max = 1
    }
    
}

public protocol PresentMenuBarControllerDataSource {
    
    /// 初始化高度
    func presentMenuBarControllerDefaultHeight(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.ContentHeight?

    /// 最小高度
    func presentMenuBarControllerMinHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat?

    /// 中等高度
    func presentMenuBarControllerMiddleHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat?

    /// 最大高度
    func presentMenuBarControllerMaxHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat?

    /// 顶部圆角
    func presentMenuBarControllerTopCornerRadius(_ presentMenuBarController: PresentMenuBarController) -> CGFloat?

    /// 惯性速度灵敏度
    func presentMenuBarControllerVelocityRate(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.DecelerationRate?

    /// 蒙层颜色 默认黑色 0.5透明度
    func presentMenuBarControllerMaskColor(_ presentMenuBarController: PresentMenuBarController) -> UIColor?

}

public extension PresentMenuBarControllerDataSource {
    
    func presentMenuBarControllerDefaultHeight(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.ContentHeight? { return nil }

    func presentMenuBarControllerMinHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat? { return nil }

    func presentMenuBarControllerMiddleHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat? { return nil }

    func presentMenuBarControllerMaxHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat? { return nil }

    func presentMenuBarControllerTopCornerRadius(_ presentMenuBarController: PresentMenuBarController) -> CGFloat? { return nil }

    func presentMenuBarControllerVelocityRate(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.DecelerationRate? { return nil }

    func presentMenuBarControllerMaskColor(_ presentMenuBarController: PresentMenuBarController) -> UIColor? { return nil }
    
}

public protocol PresentMenuBarControllerDelegate {
    
    /// 页面初始化完成
    func presentMenuBarControllerViewDidLoad(_ presentMenuBarController: PresentMenuBarController)
    
}

public extension PresentMenuBarControllerDelegate {
    
    func presentMenuBarControllerViewDidLoad(_ presentMenuBarController: PresentMenuBarController) {}
    
}

open class PresentMenuBarController: MenuBarController {
    
    /// 初始化高度 默认max
    open var defaultHeight: ContentHeight = .max

    /// 最小高度 默认0
    open var minHeight: CGFloat = 0

    /// 中等高度 默认0
    open var middleHeight: CGFloat = 0

    /// 最大高度 默认屏幕高度-状态栏高度
    open var maxHeight: CGFloat = ScreenHeight - StatusBarHeight

    /// 顶部圆角 默认0
    open var topCornerRadius: CGFloat = 0

    /// 惯性减速速率 值越大减速越快 默认normal
    open var decelerationRate: DecelerationRate = .normal {
        didSet {
            if decelerationRate.rawValue < DecelerationRate.min.rawValue {
                decelerationRate = .min
            }
            if decelerationRate.rawValue > DecelerationRate.max.rawValue {
                decelerationRate = .max
            }
        }
    }

    /// 蒙层颜色 默认黑色 0.5透明度
    open var maskColor: UIColor? = UIColor(white: 0, alpha: 0.5) {
        didSet {
            maskView?.backgroundColor = maskColor
        }
    }
    
    
    /// 蒙层
    private var maskView: UIView?

    /// 是否拖拽子视图
    private var pointInSubView = false
    
    /// 需要更新页面
    private var needUpdate = true
    

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: ScreenHeight))
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
        self.headerView = headerView;

        updateDataSource()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let menuBar = menuBar {
            clips(menuBar, with: topCornerRadius)
        } else {
            clips(horizontalScrollView, with: topCornerRadius)
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (size.width > size.height ? 0.1 : 0.25)) {
            if let menuBar = self.menuBar {
                self.clips(menuBar, with: self.topCornerRadius)
            } else {
                self.clips(self.horizontalScrollView, with: self.topCornerRadius)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let maskView = UIApplication.shared.keyWindow?.subviews.last else {
            return
        }
        self.maskView = maskView
        UIView.animate(withDuration: 0.25) {
            self.maskView?.backgroundColor = self.maskColor
        }
        DispatchQueue.main.async {
            self.updatePresentController()
        }
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25) {
            self.maskView?.backgroundColor = .clear
        }
        super.dismiss(animated: flag, completion: completion)
    }
    
    /// 重置控制器状态
    /// - Parameter animated: 动画
    open func resetPresentController(animated: Bool = true) {
        needUpdate = true
        updatePresentController()
    }
    
    private func updatePresentController(animated: Bool = true) {
        if !needUpdate {
            return
        }
        needUpdate = false
        // temp：present一个子控制器滑动到顶部会闪烁
        if viewControllers.count == 1 {
            var vcs = viewControllers
            vcs.append(UIViewController())
            viewControllers = vcs
            horizontalScrollView.isScrollEnabled = false
        }
        updateDataSource()
        let h = defaultHeight == .min ? minHeight : defaultHeight == .middle ? middleHeight : maxHeight
        verticalScrollView?.setContentOffset(CGPoint(x: 0, y: h), animated: animated)
        headerScrollTopMargin = ScreenHeight - maxHeight
    }
    
    private func updateDataSource() {
        guard let dataSource = currentViewController as? (UIViewController & PresentMenuBarControllerDataSource) else {
            return
        }
        if let defaultHeight =  dataSource.presentMenuBarControllerDefaultHeight(self) {
            self.defaultHeight = defaultHeight
        }
        if let minHeight = dataSource.presentMenuBarControllerMinHeight(self) {
            self.minHeight = minHeight
        }
        if let middleHeight = dataSource.presentMenuBarControllerMiddleHeight(self) {
            self.middleHeight = middleHeight
        }
        if let maxHeight = dataSource.presentMenuBarControllerMaxHeight(self) {
            self.maxHeight = maxHeight
        }
        if let topCornerRadius = dataSource.presentMenuBarControllerTopCornerRadius(self) {
            self.topCornerRadius = topCornerRadius
        }
        if let decelerationRate = dataSource.presentMenuBarControllerVelocityRate(self) {
            self.decelerationRate = decelerationRate
        }
        if let maskColor = dataSource.presentMenuBarControllerMaskColor(self) {
            self.maskColor = maskColor
        }
    }
    
    @objc private func tapAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    private func clips(_ view: UIView, with topCornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: topCornerRadius, height: topCornerRadius))
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        view.layer.mask = layer
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if scrollView != verticalScrollView { return }
        // 解决惯性过大时上滑会超过最大高度
        if scrollView.contentOffset.y >= maxHeight {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: maxHeight);
        }
    }
    
    open override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        if scrollView != verticalScrollView { return }
            pointInSubView = false
            if let subScrollView = currentScrollView {
                let point = scrollView.panGestureRecognizer.location(in: subScrollView.superview)
                if point.y > subScrollView.frame.minY, point.y < subScrollView.frame.maxY {
                    pointInSubView = true
                }
            }
            menuCanDrag = !pointInSubView
        
    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        if scrollView != verticalScrollView { return }
        
        let velocityPoint = scrollView.panGestureRecognizer.velocity(in: scrollView.panGestureRecognizer.view?.superview)
        
        DispatchQueue.main.async {
            
            if decelerate {
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            }
            
            var h = scrollView.contentOffset.y;
            if scrollView.contentOffset.y < self.maxHeight {
                h -= velocityPoint.y / (self.decelerationRate.rawValue * 100 + 1)
            }
            
            if h > self.middleHeight + (self.maxHeight - self.middleHeight) / 2 {
                h = self.maxHeight
            } else if h > self.minHeight + (self.middleHeight - self.minHeight) / 2 {
                h = self.middleHeight
            } else if h > self.minHeight / 2 {
                h = self.minHeight
            } else {
                h = 0
            }
            
            if h > 0 {
                UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: .curveEaseInOut) {
                    // 子视图有偏移量时 先拖拽顶部调整高度 再滑动子视图 高度会卡在半路
                    if scrollView.contentOffset.y < self.maxHeight, velocityPoint.y < 0 {
                        self.notHandleVerticalScrollView = true
                    }
                    scrollView.contentOffset = CGPoint(x: 0, y: h)
                } completion: { finished in
                    self.notHandleVerticalScrollView = false
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
}
