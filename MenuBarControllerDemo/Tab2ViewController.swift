//
//  Tab2ViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/20.
//

import UIKit

class Tab2ViewController: UIViewController {

    // 修改状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension Tab2ViewController: MenuBarProtocol {
    
    func menuBarScrollView() -> UIScrollView? {
        return view.viewWithTag(100) as? UIScrollView
    }
    
}

