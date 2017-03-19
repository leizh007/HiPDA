//
//  PresentAnimator.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/15.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// Present转场动画类型
///
/// - present: 展示
/// - dismiss: 消失
enum UIViewControllerTransitioningType {
    case present
    case dismiss
}

class PresentAnimator: NSObject {
    var duration = 0.4
    var transitioningType = UIViewControllerTransitioningType.present
}

extension PresentAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .black
        
        guard let fromView = transitionContext.viewController(forKey: .from)?.view else { return }
        guard let toView = transitionContext.viewController(forKey: .to)?.view else { return }
        
        containerView.addSubview(toView)
        
        if transitioningType == .present {
            containerView.bringSubview(toFront: toView)
            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            fromView.frame = containerView.bounds
            fromView.center = CGPoint(x: containerView.bounds.size.width / 2.0,
                                      y: containerView.bounds.size.height)
            fromView.layer.shouldRasterize = true
            fromView.layer.rasterizationScale = UIScreen.main.scale
            
            toView.frame = CGRect(x: 0,
                                  y: containerView.bounds.size.height,
                                  width: containerView.bounds.size.width,
                                  height: containerView.bounds.size.height)
            
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 1000
            transform = CATransform3DRotate(transform, CGFloat(M_PI) / 16.0, 1.0, 0, 0)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
                toView.frame = containerView.bounds
                fromView.layer.transform = transform
            }, completion: { _ in
                fromView.layer.shouldRasterize = false
                transitionContext.completeTransition(true)
            })
        } else {
            containerView.bringSubview(toFront: fromView)
            fromView.frame = containerView.bounds
            toView.frame = containerView.bounds
            toView.layer.shouldRasterize = true
            toView.layer.rasterizationScale = UIScreen.main.scale
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
                fromView.frame = CGRect(x: 0,
                                      y: containerView.bounds.size.height,
                                      width: containerView.bounds.size.width,
                                      height: containerView.bounds.size.height)
                toView.layer.transform = CATransform3DIdentity
            }, completion: { _ in
                toView.layoutIfNeeded()
                toView.layer.shouldRasterize = false
                containerView.backgroundColor = .white
                transitionContext.completeTransition(true)
            })
        }
    }
}
