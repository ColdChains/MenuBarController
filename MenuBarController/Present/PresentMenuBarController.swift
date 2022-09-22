//
//  PresentMenuBarController.swift
//  MenuBarController
//
//  Created by lax on 2022/9/22.
//

import UIKit


let ScreenBounds                = UIScreen.main.bounds
let RealWidth                   = UIScreen.main.bounds.size.width
let RealHeight                  = UIScreen.main.bounds.size.height
let ScreenWidth                 = RealWidth < RealHeight ? RealWidth : RealHeight
let ScreenHeight                = RealWidth < RealHeight ? RealHeight : RealWidth
let ScaleWidth                  = ScreenWidth / 375.0
let ScaleHeight                 = ScreenHeight / 667.0
let ScaleSize                   = ScaleWidth > 1 ? ScaleWidth : 1

let StatusBarHeight             = UIApplication.shared.statusBarFrame.size.height >= 44 ? UIApplication.shared.statusBarFrame.size.height : 20
let NavigationBarHeight         = StatusBarHeight + 44
let TabBarHeight: CGFloat       = StatusBarHeight > 20 ? 83 : 49
let HomeBarHeight: CGFloat      = StatusBarHeight > 20 ? 34 : 0
let BottomPadding: CGFloat      = StatusBarHeight > 20 ? 44 : 16

let ISiPhoneX                   = StatusBarHeight > 20 ? true : false
let ISiPhoneSE                  = ScreenWidth < 375 ? true : false


extension PresentMenuBarController {
    
    public enum ContentHeight {
        case min
        case middle
        case max
    }
    
    public enum VelocityRate: CGFloat {
        case min = 0
        case slow = 0.1
        case normal = 0.15
        case fast = 0.2
        case max = 1
    }
    
}

public protocol PresentMenuBarControllerDataSource {
    
    /// 初始化高度 默认max
    func presentMenuBarControllerDefaultHeight(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.ContentHeight

    /// 最小高度 默认0
    func presentMenuBarControllerMinHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat

    /// 中等高度 默认0
    func presentMenuBarControllerMiddleHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat

    /// 最大高度 默认屏幕高度-状态栏高度
    func presentMenuBarControllerMaxHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat

    /// 顶部圆角 默认0
    func presentMenuBarControllerTopCornerRadius(_ presentMenuBarController: PresentMenuBarController) -> CGFloat

    /// 惯性速度灵敏度 默认normal
    func presentMenuBarControllerVelocityRate(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.VelocityRate

    /// 蒙层颜色 默认黑色 0.5透明度
    func presentMenuBarControllerMaskColor(_ presentMenuBarController: PresentMenuBarController) -> UIColor?

    
}

public extension PresentMenuBarControllerDataSource {
    
    func presentMenuBarControllerDefaultHeight(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.ContentHeight { return .max }

    func presentMenuBarControllerMinHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat { return 0 }

    func presentMenuBarControllerMiddleHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat { return 0 }

    func presentMenuBarControllerMaxHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat { return ScreenHeight - NavigationBarHeight }

    func presentMenuBarControllerTopCornerRadius(_ presentMenuBarController: PresentMenuBarController) -> CGFloat { return 0 }

    func presentMenuBarControllerVelocityRate(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.VelocityRate { return .normal }

    func presentMenuBarControllerMaskColor(_ presentMenuBarController: PresentMenuBarController) -> UIColor { return UIColor(white: 0, alpha: 0.5) }
    
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
    open var maxHeight: CGFloat = 0

    /// 顶部圆角 默认0
    open var topCornerRadius: CGFloat = 0

    /// 惯性速度灵敏度 默认normal
    open var velocityRate: VelocityRate = .normal {
        didSet {
            if velocityRate.rawValue < VelocityRate.min.rawValue {
                velocityRate = .min
            }
            if velocityRate.rawValue > VelocityRate.max.rawValue {
                velocityRate = .max
            }
        }
    }

    /// 蒙层颜色 默认黑色 0.5透明度
    open var maskColor: UIColor = UIColor(white: 0, alpha: 0.5) {
        didSet {
            maskView?.backgroundColor = maskColor
        }
    }
    
    
    /// 蒙层
    private var maskView: UIView?

    /// 是否拖拽子视图
    private var pointInSubView = false
    

    open override func viewDidLoad() {
//        modalPresentationStyle = .custom
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: ScreenHeight))
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
        self.headerView = headerView;
        
        // todo: 切换控制器需要刷新
        updateDataSource()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let menuBar = menuBar {
            clips(view: menuBar, with: topCornerRadius)
        } else {
            clips(view: horizontalScrollView, with: topCornerRadius)
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
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25) {
            self.maskView?.backgroundColor = .clear
        }
        super.dismiss(animated: flag, completion: completion)
    }
    
    private func updateDataSource() {
        if let dataSource = currentViewController as? (UIViewController & PresentMenuBarControllerDataSource) {
            defaultHeight = dataSource.presentMenuBarControllerDefaultHeight(self)
            minHeight = dataSource.presentMenuBarControllerMinHeight(self)
            middleHeight = dataSource.presentMenuBarControllerMiddleHeight(self)
            maxHeight = dataSource.presentMenuBarControllerMaxHeight(self)
            topCornerRadius = dataSource.presentMenuBarControllerTopCornerRadius(self)
            velocityRate = dataSource.presentMenuBarControllerVelocityRate(self)
            maskColor = dataSource.presentMenuBarControllerMaskColor(self)
        }
        let h = defaultHeight == .min ? minHeight : defaultHeight == .middle ? middleHeight : maxHeight
        verticalScrollView?.setContentOffset(CGPoint(x: 0, y: h), animated: true)
        headerScrollTopMargin = ScreenHeight - maxHeight
    }
    
    @objc private func tapAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    private func clips(view: UIView, with topCornerRadius: CGFloat) {
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
        
        DispatchQueue.main.async {
            
            if decelerate {
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            }
            
            let velocityPoint = scrollView.panGestureRecognizer.velocity(in: scrollView.panGestureRecognizer.view?.superview)
            var h = scrollView.contentOffset.y;
            if scrollView.contentOffset.y < self.maxHeight {
                h -= velocityPoint.y / (101 - self.velocityRate.rawValue * 100)
            } // (20, 15, 10) 101-1 (101-) 0-100 (/100) 0-1
            
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
