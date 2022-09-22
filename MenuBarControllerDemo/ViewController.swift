//
//  ViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/13.
//

import UIKit
import MenuBarController

class ViewController: MenuBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        // 设置顶部间距
        self.topMargin = 44;
        
        let footerView = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        footerView.backgroundColor = .red
        footerView.text = "FooterView"
        footerView.textAlignment = .center
        // 设置底部视图
        self.footerView = footerView
        
        let menuBar = MenuBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        menuBar.backgroundColor = .red
        menuBar.dataArray = ["MenuTab1", "MenuTab2"]
        menuBar.delegate = self
        menuBar.showUnderLineView = true
        // 设置菜单栏
        self.menuBar = menuBar
        
        // 设置子控制器
        viewControllers = [Tab1ViewController(), Tab2ViewController()]
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 测试MenuBarView
//        let vc = TestViewController()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
        
        // 测试present
        // 自定义topView
        let bar = UIView(frame: CGRect(x: (UIScreen.main.bounds.size.width - 30) / 2, y: 10, width: 30, height: 4))
        bar.backgroundColor = .lightGray
        bar.layer.cornerRadius = 2
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        topView.backgroundColor = .yellow
        topView.addSubview(bar)
        
        let vc = PresentViewController()
        let pmbc = PresentMenuBarController()
        pmbc.menuBar = topView;
        pmbc.topCornerRadius = 16;
        pmbc.viewControllers = [vc]
        
        // 自定义高度 也可通过协议修改
        pmbc.minHeight = 200;
        pmbc.middleHeight = 400;
        pmbc.maxHeight = 600;
        pmbc.defaultHeight = .middle;
        
        // 接管状态栏样式
        pmbc.modalPresentationStyle = .custom
        pmbc.modalPresentationCapturesStatusBarAppearance = true
        present(pmbc, animated: true, completion: nil)
        
    }

}

