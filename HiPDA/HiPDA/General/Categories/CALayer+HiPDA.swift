//
//  CALayer+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/12.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

extension CALayer {
    
    /// 旋转
    ///
    /// - parameter angle:    旋转的弧度
    /// - parameter duration: 持续时间
    func rotate(angle: Double, duration: CFTimeInterval) {
        let rotationAtStart = value(forKeyPath: "transform.rotation")
        let rotationTransform = CATransform3DRotate(transform, CGFloat(angle), 0.0, 0.0, 1.0)
        transform = rotationTransform
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.duration = duration
        rotationAnimation.fromValue = rotationAtStart
        rotationAnimation.toValue = angle + (rotationAtStart as? Double ?? 0.0)
        
        add(rotationAnimation, forKey: nil)
    }
}
