//
//  UIViewController+Leizh007.swift
//  test
//
//  Created by leizh007 on 16/2/2.
//  Copyright © 2016年 leizh007. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayContentController(content: UIViewController, toFrame frame: CGRect) {
        addChildViewController(content)
        content.view.frame = frame
        view.addSubview(content.view)
        content.didMoveToParentViewController(self)
    }
    
    func hideContentController(content: UIViewController) {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
}