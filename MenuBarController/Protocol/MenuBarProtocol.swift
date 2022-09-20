//
//  MenuBarProtocol.swift
//  MenuBarController
//
//  Created by lax on 2022/9/19.
//

import Foundation
import UIKit

public protocol MenuBarProtocol: NSObjectProtocol {
    
    /// 返回可以滚动的视图
    func menuBarScrollView() -> UIScrollView?
    
    /// 返回菜单视图
    func menuBar() -> (UIView & MenuBarDelegate)?
    
}

extension MenuBarProtocol {
    
    func menuBarScrollView() -> UIScrollView? { return nil }
    
    func menuBar() -> (UIView & MenuBarDelegate)? { return nil }
    
}
