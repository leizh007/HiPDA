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
    /// - parameter delay:    延迟事件
    /// - parameter duration: 持续时间
    func rotate(angle: Double, delay: TimeInterval, duration: TimeInterval) {
        let transform = self.transform.rotated(by: CGFloat(angle))
        rotate(to: transform, delay: delay, duration: duration)
    }
    
    /// 旋转
    ///
    /// - parameter transform: 旋转的矩阵
    /// - parameter delay:    延迟事件
    /// - parameter duration:  持续时间
    func rotate(to transform: CGAffineTransform, delay: TimeInterval, duration: TimeInterval) {
        // FIXME: - 为了保证顺时针旋转！待优化！
        self.transform = self.transform.rotated(by: CGFloat(0.01))
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
            self.transform = transform
        }, completion: nil)
    }
}
