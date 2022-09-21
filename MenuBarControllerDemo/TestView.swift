//
//  TestView.swift
//  MenuBarControllerDemo
//
//  Created by lax on 2022/9/20.
//

import UIKit
import MenuBarController

class TestView: UIView {

    init() {
        super.init(frame: CGRect())
        
        let scrollView = UIScrollView()
        scrollView.tag = 100
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.width.height.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = "Label"
        label.textAlignment = .center
        scrollView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.height.equalTo(888)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TestView: MenuBarProtocol {
    
    func menuBarScrollView() -> UIScrollView? {
        return viewWithTag(100) as? UIScrollView
    }
    
}
