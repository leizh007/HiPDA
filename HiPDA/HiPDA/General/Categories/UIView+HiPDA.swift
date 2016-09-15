//
//  UIView+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/14.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 旋转
    ///
    /// - parameter angle:    旋转的弧度
    /// - parameter duration: 持续时间
    func rotate(angle: Double, duration: TimeInterval) {
        let transform = self.transform.rotated(by: CGFloat(M_PI))
        rotate(to: transform, duration: duration)
    }
    
    /// 旋转
    ///
    /// - parameter transform: 旋转的矩阵
    /// - parameter duration:  持续时间
    func rotate(to transform: CGAffineTransform, duration: TimeInterval) {
        UIView.animate(withDuration: duration) { 
            self.transform = transform
        }
    }
}
