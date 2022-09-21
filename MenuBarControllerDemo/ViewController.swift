//
//  ViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/13.
//

import UIKit

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
        let vc = TestViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

}
