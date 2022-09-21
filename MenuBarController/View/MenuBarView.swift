//
//  MenuBarView.swift
//  MenuBarController
//
//  Created by lax on 2022/9/14.
//

import UIKit
import SnapKit

open class MenuBarView: UIView {
    
    /// 滚动视图代理
    weak open var delegate: MenuBarScrollViewDelegate?

    /// 默认下标 默认0 需在设置views之前设置
    open var defaultIndex = 0

    /// 当前显示的视图下标
    open var currentIndex = 0 {
        willSet {
            // 竖向滚动视图不能滚动时 动态设置当前显示控制器的scrollsToTop
            if scrollsToTop, let verticalScrollView = verticalScrollView, verticalScrollView.contentSize.height <= verticalScrollView.frame.size.height {
                verticalScrollView.scrollsToTop = false
                scrollViewFrom(currentView)?.scrollsToTop = false
            }
        }
        didSet {
            if scrollsToTop, let verticalScrollView = verticalScrollView, verticalScrollView.contentSize.height <= verticalScrollView.frame.size.height {
                scrollViewFrom(currentView)?.scrollsToTop = true
            }
            menuBarWillChange(at: currentIndex)
        }
    }

    /// 当前显示的视图
    open var currentView: UIView? {
        if (0..<views.count).contains(currentIndex) {
            return views[currentIndex]
        }
        return nil
    }

    /// 当前显示视图内的滚动视图
    open var currentScrollView: UIScrollView? {
        return scrollViewFrom(currentView)
    }

    /// 竖向滚动视图
    open var verticalScrollView: MenuBarScrollView?

    /// 横向滚动视图
    open lazy var horizontalScrollView: MenuBarScrollView = {
        let scrollView = MenuBarScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.bounces = true
        return scrollView
    }()

    /// 竖向滚动视图最大偏移量
    open var verticalMaxOffset: CGFloat {
        return headerView == nil ? 0 : (headerView?.frame.size.height ?? 0 + headerBottomMargin - headerScrollTopMargin)
    }

    /// 是否点击状态栏
    open var touchStatusBar = false

    /// 此属性控制竖向滚动视图能否滚动 默认false 设置true则不会控制滚动
    open var notHandleVerticalScrollView = false

    /// 此属性控制内部滚动视图能否滚动 默认false 设置true则不会控制滚动
    open var notHandleChildScrollView = false

    // MARK: 个性化定制

    /// 内容是否嵌套 默认true 设置false则没有竖向滚动视图
    open var shouldNested = true {
        didSet {
            initScrollView()
            if let headerView = headerView {
                (verticalScrollView ?? self).addSubview(headerView)
                layoutHeaderView()
            }
            if let menuBar = menuBar {
                (verticalScrollView ?? self).addSubview(menuBar)
                layoutMenuBar()
            }
            if let footerView = footerView {
                (verticalScrollView ?? self).addSubview(footerView)
                layoutFooterView()
            }
            layoutHorizontalScrollView()
            
            let views = views
            self.views = views
        }
    }

    /// 竖向滚动视图下拉是否有弹性 默认false
    open var bounces = false

    /// 点击状态栏子视图是否回到顶部 默认true
    open var scrollsToTop = true {
        didSet {
            verticalScrollView?.scrollsToTop = scrollsToTop
        }
    }

    /// 点击菜单切换时是否有动画 默认true
    open var scrollAnimated = true

    /// 头部滑到顶部后下拉是否可固定 默认false
    open var headerCanFixed = false

    /// 是否可拖拽菜单上下滑动 默认false
    open var menuCanDrag = false

    // MARK: UI定制

    /// 竖向滚动视图顶部间距
    open var topMargin: CGFloat = 0 {
        didSet {
            if shouldNested {
                layoutVerticalScrollView()
            } else {
                layoutHeaderView()
                layoutMenuBar()
                layoutHorizontalScrollView()
            }
        }
    }

    /// 竖向滚动视图底部的间距
    open var bottomMargin: CGFloat = 0 {
        didSet {
            if shouldNested {
                layoutFooterView()
                layoutVerticalScrollView()
            } else {
                layoutFooterView()
                layoutHorizontalScrollView()
            }
        }
    }

    /// 头视图停留时顶部的间距
    open var headerScrollTopMargin: CGFloat = 0 {
        didSet {
            layoutHorizontalScrollViewHeight()
        }
    }

    /// 头视图底部与菜单的间距
    open var headerBottomMargin: CGFloat = 0 {
        didSet {
            layoutHorizontalScrollViewHeight()
            guard let _ = headerView else { return }
            if let _ = menuBar {
                layoutMenuBar()
            } else {
                layoutHorizontalScrollView()
            }
        }
    }

    /// 菜单底部的间距
    open var menuBottomMargin: CGFloat = 0 {
        didSet {
            guard let _ = menuBar else { return }
            layoutHorizontalScrollView()
        }
    }

    /// 头视图高度是否自适应 默认false
    open var headerAutoHeight = false {
        didSet {
            layoutHeaderView()
        }
    }

    /// 菜单视图高度是否自适应 默认false
    open var menuAutoHeight = false {
        didSet {
            layoutMenuBar()
        }
    }

    /// 尾视图高度是否自适应  默认false
    open var footerAutoHeight = false {
        didSet {
            layoutFooterView()
        }
    }

    // MARK: 内容定制

    /// 头视图
    open var headerView: UIView? {
        willSet {
            headerView?.removeFromSuperview()
        }
        didSet {
            if let headerView  = headerView {
                (verticalScrollView ?? self).addSubview(headerView)
                layoutHeaderView()
                if let menuBar = menuBar {
                    headerView.superview?.insertSubview(headerView, belowSubview: menuBar)
                }
            }
            layoutMenuBar()
            layoutHorizontalScrollView()
        }
    }

    /// 尾视图
    open var footerView: UIView? {
        willSet {
            footerView?.removeFromSuperview()
        }
        didSet {
            if let footerView = footerView {
                addSubview(footerView)
                layoutFooterView()
                layoutVerticalScrollView()
            }
        }
    }

    /// 菜单视图
    open var menuBar: UIView? {
        willSet {
            menuBar?.removeFromSuperview()
        }
        didSet {
            if let menuBar = menuBar {
                (verticalScrollView ?? self).addSubview(menuBar)
                layoutMenuBar()
            }
            layoutHorizontalScrollView()
        }
    }

    /// 子视图数组
    open var views: [UIView] = [] {
        willSet {
            removeSubViewObserver()
            for view in views {
                view.removeFromSuperview()
            }
        }
        didSet {
            if views.count == 0 { return }
            
            for i in 0..<views.count {
                
                let subView = views[i]
                horizontalScrollView.addSubview(subView)
                subView.snp.remakeConstraints { make in
                    if i == 0 {
                        make.left.equalTo(horizontalScrollView)
                    } else if i == views.count - 1 {
                        make.left.equalTo(views[i - 1].snp.right)
                        make.right.equalTo(horizontalScrollView)
                    } else {
                        make.left.equalTo(views[i - 1].snp.right)
                    }
                    make.top.bottom.width.height.equalToSuperview()
                }
                
                // 添加观察者
                if let menuBarView = subView as? MenuBarView {
                    for view in menuBarView.views {
                        if let scrollView = scrollViewFrom(view) {
                            if observerDictionary[String(format: "%p", scrollView)] == nil {
                                observerDictionary[String(format: "%p", scrollView)] = 1
                                scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
                            }
                            scrollView.scrollsToTop = false
                            scrollView.alwaysBounceVertical = true
                        }
                        menuBarView.scrollsToTop = scrollsToTop
                    }
                } else {
                    if let scrollView = scrollViewFrom(subView) {
                        if observerDictionary[String(format: "%p", scrollView)] == nil {
                            observerDictionary[String(format: "%p", scrollView)] = 1
                            scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
                        }
                        scrollView.scrollsToTop = false
                        scrollView.alwaysBounceVertical = true
                    }
                }
                
            }
            
            // 设置弹性状态
            for view in views {
                if let menuBarView = view as? MenuBarView {
                    menuBarView.alwaysBounceHorizontal = true
                }
            }
            
            scroll(to: defaultIndex, animated: false)
            
            offsetDictionary.removeAll()
            
        }
    }
    

    /// 竖向滚动视图是否可滑动 默认true
    private var outsideCanScroll = true

    /// 内部滚动视图是否可滑动 默认false
    private var insideCanScroll = false

    /// 滚动视图偏移量记录
    private var offsetDictionary: [String : CGFloat] = [:]
    
    /// 添加观察者记录
    private var observerDictionary: [String : CGFloat] = [:]
    
    /// 弹性管理 记录竖向滚动视图是否有弹性
    private var alwaysBounceHorizontal = false
    
    // MARK: - layout
    
    private func layoutVerticalScrollView() {
        guard let superview = verticalScrollView?.superview else { return }
        verticalScrollView?.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topMargin)
            make.bottom.equalTo(footerView?.snp.top ?? superview).offset(footerView == nil ? -bottomMargin : 0)
        }
    }
    
    private func layoutHorizontalScrollView() {
        guard let superview = horizontalScrollView.superview else { return }
        horizontalScrollView.snp.remakeConstraints({ make in
            make.top.equalTo(menuBar?.snp.bottom ?? headerView?.snp.bottom ?? superview).offset(menuBar != nil ? menuBottomMargin : headerView != nil ? headerBottomMargin : 0)
            make.bottom.equalTo(footerView != nil ? 0 : shouldNested ? 0 : -bottomMargin)
            make.left.right.equalToSuperview()
            if shouldNested {
                make.width.height.equalToSuperview()
            }
        })
        if shouldNested {
            layoutHorizontalScrollViewHeight()
        }
    }
    
    private func layoutHorizontalScrollViewHeight() {
        guard let _ = horizontalScrollView.superview else { return }
        let horizontalViewHeightOffset = (headerView != nil ? headerScrollTopMargin : 0) + (menuBar != nil ? (menuBar?.frame.size.height ?? 0 + menuBottomMargin) : 0)
        horizontalScrollView.snp.updateConstraints({ make in
            make.height.equalToSuperview().offset(-horizontalViewHeightOffset)
        })
    }
    
    private func layoutHeaderView() {
        guard let _ = headerView?.superview else { return }
        headerView?.snp.remakeConstraints({ make in
            make.top.equalTo(shouldNested ? 0 : topMargin)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            if !headerAutoHeight {
                make.height.equalTo(headerView?.frame.size.height ?? 0)
            }
        })
    }
    
    private func layoutFooterView() {
        guard let _ = footerView?.superview else { return }
        footerView?.snp.remakeConstraints({ make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(shouldNested ? 0 : -bottomMargin)
            make.width.equalToSuperview()
            if !footerAutoHeight {
                make.height.equalTo(footerView?.frame.size.height ?? 0)
            }
        })
    }
    
    private func layoutMenuBar() {
        guard let superview = menuBar?.superview else { return }
        menuBar?.snp.remakeConstraints({ make in
            make.top.equalTo(headerView?.snp.bottom ?? superview).offset(headerView != nil ? headerBottomMargin : shouldNested ? 0 : topMargin)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
            if !menuAutoHeight {
                make.height.equalTo(menuBar?.frame.size.height ?? 0)
            }
        })
    }
    
    private func initScrollView() {
        if (shouldNested) {
            if verticalScrollView == nil {
                let scrollView = MenuBarScrollView()
                scrollView.delegate = self
                scrollView.gestureDelegate = self
                scrollView.shouldRecognizeSimultaneously = true
                addSubview(scrollView)
                verticalScrollView = scrollView
                layoutVerticalScrollView()
                // 添加观察者
                if observerDictionary[String(format: "%p", scrollView)] == nil {
                    observerDictionary[String(format: "%p", scrollView)] = 1
                    scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
                }
            }
        } else {
            // 移除观察者
            if let verticalScrollView = verticalScrollView, observerDictionary[String(format: "%p", verticalScrollView)] != nil {
                observerDictionary.removeValue(forKey: String(format: "%p", verticalScrollView))
                verticalScrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            }
            verticalScrollView?.removeFromSuperview()
            verticalScrollView = nil
        }
        
        (verticalScrollView ?? self).addSubview(horizontalScrollView)
        horizontalScrollView.snp.remakeConstraints { make in
            make.top.left.right.bottom.width.height.equalToSuperview()
        }
    }
    
    // MARK: - 系统方法
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initScrollView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        guard let verticalScrollView = verticalScrollView else { return }
        if observerDictionary[String(format: "%p", verticalScrollView)] != nil {
            observerDictionary.removeValue(forKey: String(format: "%p", verticalScrollView))
            verticalScrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
        }
        removeSubViewObserver()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath != "contentOffset" {
            return
        }
        
        if let new = change?[.newKey] as? CGPoint, let old = change?[.oldKey] as? CGPoint, new.y == old.y {
            return
        }
        
        guard let scrollView = object as? UIScrollView, let verticalScrollView = verticalScrollView else { return }
        
        let key = String(format: "%p", scrollView)
        var oldOffset = offsetDictionary[key] ?? 0
        offsetDictionary[key] = scrollView.contentOffset.y
        
        if scrollView == verticalScrollView {
            
            if currentView == nil {
                return
            }
            
            if notHandleVerticalScrollView {
                return
            }
            
            // 往下滑
            if scrollView.contentOffset.y < oldOffset {
                
                // 菜单可以拖拽
                if menuCanDrag {
                    var pointInSubView = false
                    if let subScrollView = scrollViewFrom(currentView) {
                        let point = scrollView.panGestureRecognizer.location(in: subScrollView.superview)
                        if point.y > subScrollView.frame.minY && point.y < subScrollView.frame.maxY {
                            pointInSubView = true
                        }
                        // 不是拖拽头部且子视图有偏移时保持不动(拖拽菜单下滑不处理)
                        if pointInSubView && subScrollView .contentOffset.y > 0 {
                            offsetDictionary[key] = oldOffset
                            scrollView.contentOffset = CGPoint(x: 0, y: oldOffset)
                        }
                    }
                } else {
                    // 子视图滑到最顶部时竖向滚动视图可以滑动
                    if outsideCanScroll {
                        // header滑到顶部后下拉是否可固定时保持不动(点击状态栏的情况不处理)
                        if headerCanFixed && !touchStatusBar {
                            offsetDictionary[key] = oldOffset
                            scrollView.contentOffset = CGPoint(x: 0, y: oldOffset)
                        }
                    } else {
                        // 判断子视图内容可否滑动
                        var canScroll = false
                        if let menuBarView = currentView as? MenuBarView {
                            if let subScrollView = scrollViewFrom(menuBarView.currentView), (subScrollView.contentSize.height > subScrollView.frame.size.height || subScrollView.contentOffset.y > 0) {
                                canScroll = true
                            }
                        } else {
                            if let subScrollView = scrollViewFrom(currentView), (subScrollView.contentSize.height > subScrollView.frame.size.height || subScrollView.contentOffset.y > 0) {
                                canScroll = true
                            }
                        }
                        // 子视图可以滑动时保持不动(点击状态栏的情况不处理)
                        if canScroll && !touchStatusBar {
                            offsetDictionary[key] = oldOffset
                            scrollView.contentOffset = CGPoint(x: 0, y: oldOffset)
                        }
                    }
                }
                
            } else { // 往上滑
                
                // 偏移量达到最大时不可滑动，子视图可以滑动
                if scrollView.contentOffset.y >= verticalMaxOffset {
                    // 偏移量达到最大时保持不动
                    offsetDictionary[key] = verticalMaxOffset
                    scrollView.contentOffset = CGPoint(x: 0, y: verticalMaxOffset)
                    insideCanScroll = true
                    outsideCanScroll = false
                } else {
                    insideCanScroll = false
                }
                
                // 没有弹性并且子视图偏移量小于0时保持不动
                if !bounces, let subScrollView = scrollViewFrom(currentView), subScrollView.contentOffset.y < 0 {
                    offsetDictionary[key] = oldOffset
                    scrollView.contentOffset = CGPoint(x: 0, y: oldOffset)
                }
                
            }
            
            // 没有弹性并且偏移量小于0时保持不动
            if !bounces && scrollView.contentOffset.y < 0 {
                offsetDictionary[key] = 0
                scrollView.contentOffset = CGPoint()
            }
            
        } else { // 子视图
            
            delegate?.menuBarScrollViewDidScroll(scrollView, type: .child)
            
            if notHandleChildScrollView {
                return
            }
            
            if verticalScrollView.contentSize.height <= verticalScrollView.frame.size.height {
                return
            }
            
            // 往下滑
            if scrollView.contentOffset.y < oldOffset {
                
                // 子视图滑到最顶部时不可滑动，竖向滚动视图可以滑动
                if scrollView.contentOffset.y < 0 {
                    // 竖向滚动视图没有弹性并且偏移量为0时可以滑动
                    if bounces || (!bounces && verticalScrollView.contentOffset.y > 0) {
                        // header可以固定时可以滑动
                        if !headerCanFixed, scrollView.contentOffset.y != 0 {
                            offsetDictionary[key] = 0
                            scrollView.contentOffset = CGPoint()
                        }
                    }
                    outsideCanScroll = true
                    insideCanScroll = false
                } else {
                    if !touchStatusBar {
                        outsideCanScroll = false
                    }
                }
                
            } else { // 往上滑
                
                // 竖向滚动视图偏移量达到最大时子视图可以滑动
                if !insideCanScroll && oldOffset >= 0 {
                    // 竖向滚动视图没有弹性并且偏移量为0时可以滑动
                    if bounces || (!bounces && verticalScrollView.contentOffset.y > 0) {
                        // header可以固定时可以滑动
                        if !headerCanFixed, scrollView.contentOffset.y != oldOffset {
                            offsetDictionary[key] = oldOffset
                            scrollView.contentOffset = CGPoint(x: 0, y: oldOffset)
                        }
                    }
                    if oldOffset < 0, scrollView.contentOffset.y > 0 {
                        oldOffset = 0
                        if scrollView.contentOffset.y != oldOffset {
                            offsetDictionary[key] = oldOffset
                            scrollView.contentOffset = CGPoint(x: 0, y: oldOffset)
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    // MARK: - 自定义方法
    
    /// 移除观察者
    private func removeSubViewObserver() {
        if observerDictionary.count == 0 {
            return
        }
        if let verticalScrollView = verticalScrollView, observerDictionary[String(format: "%p", verticalScrollView)] != nil, observerDictionary.count == 1 {
            return
        }
        for subView in views {
            if let subMenuBarView = subView as? MenuBarView {
                for view in subMenuBarView.views {
                    if let scrollView = scrollViewFrom(view), observerDictionary[String(format: "%p", scrollView)] != nil {
                        observerDictionary.removeValue(forKey: String(format: "%p", scrollView))
                    }
                }
            } else {
                if let scrollView = scrollViewFrom(subView), observerDictionary[String(format: "%p", scrollView)] != nil {
                    observerDictionary.removeValue(forKey: String(format: "%p", scrollView))
                }
            }
        }
    }
    
    /// 返回视图里可以滑动的视图
    private func scrollViewFrom(_ view: UIView?) -> UIScrollView? {
        guard let view = view else {
            return nil
        }
        if view is UIScrollView {
            return view as? UIScrollView
        }
        if let v = view as? (UIView & MenuBarProtocol) {
            return v.menuBarScrollView()
        }
        return nil;
    }
    
    /// 返回菜单视图
    private func menuBarFrom(_ view: UIView?) -> (UIView & MenuBarDelegate)? {
        var menuBar = view
        if let v = view as? (UIView & MenuBarProtocol) {
            menuBar = v.menuBar()
        }
        if let v = menuBar as? (UIView & MenuBarDelegate) {
            return v
        }
        return nil
    }
    
    /// 竖向滚动视图回到顶部
    open func scrollToTop(with animated: Bool) {
        if verticalScrollView?.contentOffset.y == 0 { return; }
        touchStatusBar = true
        outsideCanScroll = true
        verticalScrollView?.isTouching = true
        verticalScrollView?.setContentOffset(CGPoint(), animated: animated)
    }
    
    /// 子视图回到顶部
    open func subScrollViewScrollToTop(with animated:Bool) {
        if let currentView = currentView as? MenuBarView {
            outsideCanScroll = true
            verticalScrollView?.isTouching = true
            currentView.scrollToTop(with: animated)
            currentView.subScrollViewScrollToTop(with: animated)
        } else {
            if let scrollView = scrollViewFrom(currentView), scrollView.contentOffset.y > 0 {
                outsideCanScroll = true
                verticalScrollView?.isTouching = true
                scrollView.setContentOffset(CGPoint(), animated: animated)
            }
        }
    }
    
    /// 滑动到指定位置
    open func scroll(to index: Int, animated: Bool) {
        horizontalScrollView.setContentOffset(CGPoint(x: CGFloat(index) * horizontalScrollView.bounds.size.width, y: 0), animated: animated)
        currentIndex = index
    }
    
    /// 菜单选中事件
    private func menuBarWillChange(at index: Int) {
        if menuBarShouldChange(at: index) {
            menuBarDidChanged(at: index)
        }
    }

    /// 菜单是否需要选中 默认返回true 返回false则滑动子视图时菜单不会有选中态
    open func menuBarShouldChange(at index: Int) -> Bool {
        return true
    }

    /// 菜单已经选中
    open func menuBarDidChanged(at index: Int) {
        if let menuBar = menuBarFrom(menuBar) {
            menuBar.menuBarDidSelect(menuBar, at: index)
        }
        if let menuBar = menuBarFrom(headerView) {
            menuBar.menuBarDidSelect(menuBar, at: index)
        }
        if let menuBar = menuBarFrom(footerView) {
            menuBar.menuBarDidSelect(menuBar, at: index)
        }
    }
    
}

extension MenuBarView: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == verticalScrollView {
            delegate?.menuBarScrollViewDidScroll(scrollView, type: .vertical)
        } else if scrollView == horizontalScrollView {
            if horizontalScrollView.isDragging {
                let index = Int((scrollView.contentOffset.x + scrollView.bounds.size.width / 2) / scrollView.bounds.size.width)
                if currentIndex != index {
                    currentIndex = index
                }
            }
            delegate?.menuBarScrollViewDidScroll(scrollView, type: .horizontal)
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == verticalScrollView {
            alwaysBounceHorizontal = scrollView.alwaysBounceHorizontal
            if scrollView.alwaysBounceHorizontal {
                scrollView.alwaysBounceHorizontal = false
            }
            delegate?.menuBarScrollViewWillBeginDragging(scrollView, type: .vertical)
        } else if scrollView == horizontalScrollView {
            delegate?.menuBarScrollViewWillBeginDragging(scrollView, type: .horizontal)
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == verticalScrollView {
            if alwaysBounceHorizontal {
                verticalScrollView?.alwaysBounceHorizontal = true
            }
            if !decelerate {
                verticalScrollView?.isTouching = false
            }
            delegate?.menuBarScrollViewDidEndDragging(scrollView, willDecelerate: decelerate, type: .vertical)
        } else if scrollView == horizontalScrollView {
            if !decelerate {
                horizontalScrollView.isTouching = false
            }
            delegate?.menuBarScrollViewDidEndDragging(scrollView, willDecelerate: decelerate, type: .horizontal)
        }
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == verticalScrollView {
            delegate?.menuBarScrollViewWillBeginDecelerating(scrollView, type: .vertical)
        } else if scrollView == horizontalScrollView {
            delegate?.menuBarScrollViewWillBeginDecelerating(scrollView, type: .horizontal)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == verticalScrollView {
            verticalScrollView?.isTouching = false
            delegate?.menuBarScrollViewDidEndDecelerating(scrollView, type: .vertical)
        } else if scrollView == horizontalScrollView {
            delegate?.menuBarScrollViewDidEndDecelerating(scrollView, type: .horizontal)
        }
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if touchStatusBar { return false }
        touchStatusBar = true
        subScrollViewScrollToTop(with: true)
        return true
    }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        touchStatusBar = false
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        touchStatusBar = false
    }
    
}

extension MenuBarView: MenuBarDelegate {

    open func menuBarDidSelect(_ menuBar: (UIView & MenuBarDelegate), at index: Int) {
        scroll(to: index, animated: scrollAnimated)
    }

}

extension MenuBarView: MenuBarScrollViewGestureDelegate {

    open func menuBarScrollView(_ menuBarScrollView: MenuBarScrollView, gestureShouldRecognizeSimultaneouslyWith responder: UIResponder) -> Bool {
        for view in views {
            if let menuBarView = view as? MenuBarView {
                for subView in menuBarView.views {
                    if responder == scrollViewFrom(subView) {
                        return true
                    }
                }
            } else {
                if responder == scrollViewFrom(view) {
                    return true
                }
            }
        }
        return false
    }

}
