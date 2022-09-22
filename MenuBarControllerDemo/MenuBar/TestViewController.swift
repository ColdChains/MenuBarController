//
//  Tab2ContentViewController.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/20.
//

import UIKit
import MenuBarController

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        let menuBarView = MenuBarView()
        menuBarView.bounces = true
        
        let red = TestView()
        red.backgroundColor = .red
        let green = UIView()
        green.backgroundColor = .green
        menuBarView.views = [red, green]

        let header = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        header.backgroundColor = .orange
        menuBarView.headerView = header

        let menuBar = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        menuBar.backgroundColor = .yellow
        menuBarView.menuBar = menuBar

        view.addSubview(menuBarView)
        menuBarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }

}
