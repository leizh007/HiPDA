//
//  UIApplication+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/3.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        return controller
    }
}

