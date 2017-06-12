//
//  UITabBarController+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

extension UITabBarController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
        }
    }
}
