//
//  UIViewController+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/15.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

extension UIViewController {
    /// 根viewController
    var ancestorViewContoller: UIViewController {
        var resultViewController = self
        while let controller = resultViewController.parent {
            resultViewController = controller
        }
        
        return resultViewController
    }
}
