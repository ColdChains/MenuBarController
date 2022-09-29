//
//  PresentViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/22.
//

import UIKit
import MenuBarController

class PresentViewController: UIViewController {

    // 修改状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension PresentViewController: MenuBarProtocol {
    
    func menuBarScrollView() -> UIScrollView? {
        return view.viewWithTag(100) as? UIScrollView
    }
    
}

extension PresentViewController: PresentMenuBarControllerDataSource {
    
    // 最小高度
    func presentMenuBarControllerMinHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat {
        return 200
    }
    
    func presentMenuBarControllerMiddleHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat {
        return 400
    }
    
    // 最大高度
    func presentMenuBarControllerMaxHeight(_ presentMenuBarController: PresentMenuBarController) -> CGFloat {
        return 600
    }
    
    // 初始化高度
    func presentMenuBarControllerDefaultHeight(_ presentMenuBarController: PresentMenuBarController) -> PresentMenuBarController.ContentHeight {
        return .middle
    }
    
}
