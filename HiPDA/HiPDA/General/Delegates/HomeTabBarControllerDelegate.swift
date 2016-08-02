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
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBar = tabBarController.tabBar
        
        /// 获取选中的UITabBarButton
        /// UITabBar的子视图为背景视图和UITabBarButton的数组，所以这里下标要加1
        let index = tabBarController.selectedIndex + 1
        let endIndex = tabBar.subviews.endIndex
        guard endIndex > index && endIndex > 1 else { return }
        let tabBarButton = tabBar.subviews[index]
        
        guard let imageView = tabBarButton.subviews.first as? UIImageView else {
            return
        }
        
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
