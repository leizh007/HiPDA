//
//  UIImage+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 取得view的截图
    ///
    /// - parameter view:  待截图的view
    /// - parameter frame: 待截图区域（相较于view）
    ///
    /// - returns: 截图
    @nonobjc
    static func snapshot(of view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
