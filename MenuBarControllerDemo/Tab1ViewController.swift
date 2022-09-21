//
//  Tab1ViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/20.
//

import UIKit
import MenuBarController

class Tab1ViewController: MenuBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置顶部停留间距
        headerScrollTopMargin = 0
        // 关闭切换动画
        scrollAnimated = false
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
        headerView.backgroundColor = .green
        // 设置顶部视图
        self.headerView = headerView
        
        let menuBar = MenuBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        menuBar.backgroundColor = .red
        menuBar.dataArray = ["SubTab1", "SubTab2", "SubTab3"]
        menuBar.delegate = self
        // 设置菜单栏
        self.menuBar = menuBar
        
        let vc1 = Tab1ContentViewController()
        vc1.view.backgroundColor = .orange
        let vc2 = Tab1ContentViewController()
        vc2.view.backgroundColor = .yellow
        let vc3 = Tab1ContentViewController()
        vc3.view.backgroundColor = .cyan
        // 设置子控制器
        viewControllers = [vc1, vc2, vc3]
    }

}
