//
//  MenuBar.swift
//  MenuBarController
//
//  Created by lax on 2022/9/14.
//

import UIKit

public protocol MenuBarDelegate: NSObjectProtocol {
    
    /// 点击菜单按钮
    func menuBarDidSelect(_ menuBar: (UIView & MenuBarDelegate), at index: Int)
    
}

public extension MenuBarDelegate {
    
    func menuBarDidSelect(_ menuBar: (UIView & MenuBarDelegate), at index: Int) {}
    
}

open class MenuBar: UIScrollView {

    public enum Style {
        /// 宽度固定
        case fixed
        /// 宽度自适应 可左右滑动
        case scroll
    }
    
    public enum UnderLineAlignment: Int {
        case left = -1
        case center
        case right
    }
    
    /// 样式
    open var style: Style = .fixed

    /// 数据源
    open var dataArray: [String] = [] {
        didSet {
            initView()
        }
    }

    /// 当前下标
    open var currentIndex = 0 {
        willSet {
            if (0..<buttonArray.count).contains(currentIndex) {
                buttonArray[currentIndex].titleLabel?.font = textFont
                buttonArray[currentIndex].setTitleColor(textColor, for: .normal)
            }
        }
        didSet {
            if (0..<buttonArray.count).contains(currentIndex) {
                buttonArray[currentIndex].titleLabel?.font = selectTextFont
                buttonArray[currentIndex].setTitleColor(selectTextColor, for: .normal)
                initUnderLineViewFrame()
            }
            if currentIndex != oldValue {
                let autoPosition = autoPosition
                self.autoPosition = autoPosition
            }
        }
    }

    /// 内边距 默认0
    open var edgeInsets = UIEdgeInsets() {
        didSet {
            initView()
        }
    }

    /// 菜单间距(Scroll样式生效) 默认24
    open var itemMargin: CGFloat = 24 {
        didSet {
            initView()
        }
    }

    /// 选中项在边缘是否自动调整位置(Scroll样式生效) 默认NO
    open var autoPosition = false {
        didSet {
            if autoPosition {
                UIView.animate(withDuration: 0.25) {
                    self.checkPositon()
                }
            }
        }
    }

    /// 未选中文字颜色 默认lightGrayColor
    open var textColor = UIColor.lightGray {
        didSet {
            for button in buttonArray {
                button.setTitleColor(textColor, for: .normal)
            }
            if (0..<buttonArray.count).contains(currentIndex) {
                buttonArray[currentIndex].setTitleColor(selectTextColor, for: .normal)
            }
        }
    }

    /// 选中文字颜色 默认darkTextColor
    open var selectTextColor = UIColor.darkText {
        didSet {
            if (0..<buttonArray.count).contains(currentIndex) {
                buttonArray[currentIndex].setTitleColor(selectTextColor, for: .normal)
            }
        }
    }

    /// 未选中文字大小 默认14
    open var textFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            for button in buttonArray {
                button.titleLabel?.font = textFont
            }
            if (0..<buttonArray.count).contains(currentIndex) {
                buttonArray[currentIndex].titleLabel?.font = selectTextFont
            }
        }
    }

    /// 选中文字大小 默认14
    open var selectTextFont = UIFont(name: "PingFangSC-Medium", size: 14) {
        didSet {
            if (0..<buttonArray.count).contains(currentIndex) {
                buttonArray[currentIndex].titleLabel?.font = selectTextFont
            }
        }
    }

    /// 是否显示下划线 默认NO
    open var showUnderLineView = false {
        didSet {
            underLineView?.isHidden = !showUnderLineView
            initUnderLineViewFrame()
        }
    }

    /// 下划线宽度跟随文字 默认YES
    open var underLineViewAutoWidth = true {
        didSet {
            initUnderLineViewFrame()
        }
    }

    /// 下划线与文字对齐方式 默认居中
    open var underLineViewAlignment: UnderLineAlignment = .center {
        didSet {
            initUnderLineViewFrame()
        }
    }
    
    /// 下划线的宽度 默认16
    open var underLineViewWidth: CGFloat = 16 {
        didSet {
            initUnderLineViewFrame()
        }
    }
    
    /// 下划线的高度 默认2
    open var underLineViewHeight: CGFloat = 2 {
        didSet {
            initUnderLineViewFrame()
        }
    }
    
    /// 下划线的底部间距 默认1
    open var underLineViewBottom: CGFloat = 1 {
        didSet {
            initUnderLineViewFrame()
        }
    }
    
    /// 下划线的圆角 默认0
    open var underLineViewCornerRadius: CGFloat = 0 {
        didSet {
            underLineView?.layer.cornerRadius = underLineViewCornerRadius
        }
    }
    
    /// 下划线的颜色 默认F8F8F8
    open var underLineViewColor = UIColor(white: 248.0 / 255.0, alpha: 1) {
        didSet {
            underLineView?.backgroundColor = underLineViewColor
        }
    }
    
    /// 下划线 若自定义View则underLineViewAutoWidth自动置为NO、underLineViewColor自动置为clearColor
    open var underLineView: UIView?  {
        willSet {
            underLineView?.removeFromSuperview()
        }
        didSet {
            guard let underLineView = underLineView else { return }
            underLineViewWidth = underLineView.frame.size.width
            underLineViewHeight = underLineView.frame.size.height
            underLineViewCornerRadius = underLineView.layer.cornerRadius
            underLineViewColor = .clear
            underLineViewAutoWidth = false
            showUnderLineView = true
            addSubview(underLineView)
            sendSubviewToBack(underLineView)
            initUnderLineViewFrame()
        }
    }
    
    private var buttonArray: [UIButton] = []
    
    /// 构造方法(使用frame布局)
    /// @param frame 位置
    /// @param style 样式
    public convenience init(frame: CGRect, style: Style) {
        self.init(frame: frame)
        self.style = style
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        bounces = true
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initView() {
        for button in buttonArray {
            button.removeFromSuperview()
        }
        switch style {
        case .fixed:
            layoutWithFixedStyle()
            break
        case .scroll:
            layoutWithScrollStyle()
            break
        }
        initUnderLineViewFrame()
    }
    
    private func layoutWithFixedStyle() {
        if dataArray.count == 0 { return }
        
        var x = edgeInsets.left
        let w = frame.size.width / CGFloat(dataArray.count)
        let h = bounds.size.height - edgeInsets.top - edgeInsets.bottom
        
        buttonArray.removeAll()
        
        for i in 0..<dataArray.count {
            let button = UIButton()
            button.tag = 100 + i
            button.titleLabel?.font = textFont
            button.setTitle(dataArray[i], for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            addSubview(button)
            buttonArray.append(button)
            
            button.frame = CGRect(x: x, y: edgeInsets.top, width: w, height: h)
            x += w
        }
        x += edgeInsets.right
        
        contentSize = CGSize(width: x, height: bounds.size.height)
    }
    
    private func layoutWithScrollStyle() {
        if dataArray.count == 0 { return }
        
        var x = edgeInsets.left - itemMargin / 2
        var w: CGFloat
        let h = bounds.size.height - edgeInsets.top - edgeInsets.bottom
        
        buttonArray.removeAll()
        
        for i in 0..<dataArray.count {
            let button = UIButton()
            button.tag = 100 + i
            button.titleLabel?.font = textFont
            button.setTitle(dataArray[i], for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            addSubview(button)
            buttonArray.append(button)
            
            w = getTitleWidth(with: i)
            button.frame = CGRect(x: x, y: edgeInsets.top, width: w + itemMargin, height: h)
            x += w + itemMargin
        }
        x += edgeInsets.right - itemMargin / 2
        
        contentSize = CGSize(width: x, height: bounds.size.height)
    }
    
    private func getTitleWidth(with index: Int) -> CGFloat {
        if !(0..<dataArray.count).contains(index) { return 0 }
        let maxSize = CGSize(width: frame.size.width, height: frame.size.height)
        let dic = [NSAttributedString.Key.font : buttonArray[index].titleLabel?.font]
        let rect = dataArray[index].boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: dic as [NSAttributedString.Key : Any], context: nil)
        return ceil(rect.size.width)
    }
    
    private func initUnderLineViewFrame() {
        if dataArray.count == 0 {
            underLineView?.frame = CGRect()
            return
        }
        if !showUnderLineView || !(0..<buttonArray.count).contains(currentIndex) {
            return
        }
        if underLineView == nil {
            let underLineView = UIView()
            underLineView.layer.cornerRadius = underLineViewCornerRadius
            underLineView.backgroundColor = underLineViewColor
            addSubview(underLineView)
            sendSubviewToBack(underLineView)
            self.underLineView = underLineView
        }
        var w: CGFloat
        if underLineViewAutoWidth {
            w = getTitleWidth(with: currentIndex)
        } else {
            w = underLineViewWidth
        }
        var x = buttonArray[currentIndex].center.x - w / 2
        if !underLineViewAutoWidth && underLineViewAlignment != .center {
            x += CGFloat(underLineViewAlignment.rawValue) * (getTitleWidth(with: currentIndex) - underLineViewWidth) / 2
        }
        underLineView?.frame = CGRect(x: x, y: frame.size.height - edgeInsets.bottom - underLineViewHeight - underLineViewBottom, width: w, height: underLineViewHeight)
    }
    
    private func checkPositon() {
        if contentSize.width <= frame.size.width {
            return
        }
        let frame = buttonArray[currentIndex].frame;
        let rect = convert(frame, to: superview)
        let margin: CGFloat = 60;
        
        if rect.origin.x < margin && contentOffset.x > 0 {
            let x = frame.origin.x - margin
            setContentOffset(CGPoint(x: max(x, 0), y: 0), animated: true)
        }
        if (rect.origin.x + rect.size.width > bounds.size.width - margin && contentOffset.x < contentSize.width) {
            let x = frame.origin.x - (bounds.size.width - margin - frame.size.width)
            setContentOffset(CGPoint(x: min(x, contentSize.width - bounds.size.width), y: 0), animated: true)
        }
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        (delegate as? MenuBarDelegate)?.menuBarDidSelect(self, at: sender.tag - 100)
    }

}

extension MenuBar: MenuBarDelegate {
    
    open func menuBarDidSelect(_ menuBar: (UIView & MenuBarDelegate), at index: Int) {
        currentIndex = index
    }
    
}
