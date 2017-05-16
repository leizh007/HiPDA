//
//  HomeTabBarControllerDelegate.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/28.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 主页TabBarController的Delegate
class HomeTabBarControllerDelegate: NSObject, UITabBarControllerDelegate {
    var lastSelectedIndex = 0
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex != lastSelectedIndex {
            lastSelectedIndex = tabBarController.selectedIndex
        } else if lastSelectedIndex == C.Number.homeViewControllerIndex {
            NotificationCenter.default.post(name: .HomeViewControllerTabRepeatedSelected, object: nil)
        }
        
        /// 处理动画相关
        let tabBar = tabBarController.tabBar
        guard let tabbarItem = tabBar.selectedItem else { return }
        
        var selectedImageView: UIImageView?
        
        for tabBarButton in tabBar.subviews {
            let (imageView, label) = tabBarButton.subviews.reduce((nil, nil)) { (result, view) in
                return (result.0 ?? view as? UIImageView, result.1 ?? view as? UILabel)
            }
            
            if imageView != nil && label != nil && tabbarItem.title == label?.text {
                selectedImageView = imageView
                break
            }
        }
        
        guard let imageView = selectedImageView else { return }
        
        /// 给imageView添加动画，动画参数待优化！
        UIView.animate(withDuration: 0.15,
                       animations: {
                        imageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }, completion: { (_) in
                UIView.animate(withDuration: 0.1,
                               animations: {
                                imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }, completion: { (_) in
                        UIView.animate(withDuration: 0.03,
                                       animations: { 
                                        imageView.transform = CGAffineTransform.identity
                        })
                })
        })
    }
}
