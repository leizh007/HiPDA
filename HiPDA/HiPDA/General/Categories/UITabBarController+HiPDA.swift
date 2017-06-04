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
            tabBar.unselectedItemTintColor = #colorLiteral(red: 0.3977642059, green: 0.4658440351, blue: 0.5242295265, alpha: 1)
        }
    }
}
