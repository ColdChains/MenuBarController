//
//  Tab1ContentViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/20.
//

import UIKit
import MenuBarController

class Tab1ContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension Tab1ContentViewController: MenuBarProtocol {
    
    func menuBarScrollView() -> UIScrollView? {
        return view.viewWithTag(100) as? UIScrollView
    }
    
}
