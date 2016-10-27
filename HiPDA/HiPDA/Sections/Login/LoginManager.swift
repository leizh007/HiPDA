//
//  LoginManager.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 登录管理
class LoginManager: Bootstrapping {
    /// 主页
    private var homeViewController: UIViewController?
    
    func bootstrap(bootstrapped: Bootstrapped) throws {
        if let _ = Settings.shared.activeAccount {
            
        } else {
            let loginViewController = LoginViewController.load(from: UIStoryboard.main)
            guard let window = UIApplication.shared.windows.safe[0] else { return }
            homeViewController = window.rootViewController
            homeViewController?.view.layoutIfNeeded()
            window.rootViewController = loginViewController
            
            loginViewController.loggedInCompletion = { [weak self] account in
                guard let `self` = self else { return }
                Settings.shared.add(account: account)
                Settings.shared.activeAccount = account
                EventBus.shared.dispatch(ChangeAccountAction(account: account))
                
                guard let window = UIApplication.shared.windows.safe[0] else { return }
                /// 这个颜色是navigationBar的颜色
                window.backgroundColor = #colorLiteral(red: 0.9763647914, green: 0.9765316844, blue: 0.9764705882, alpha: 1)
                /// 动画过程中没有statusBar，所以navigationBar的高度会少20
                self.homeViewController?.view.frame = CGRect(x: 0,
                                                             y: StatusBarHeight,
                                                             width: ScreenWidth,
                                                             height: ScreenHeigh - StatusBarHeight)
                
                UIView.transition(with: window, duration: 0.75, options: [.transitionFlipFromRight, .curveEaseInOut], animations: {
                    window.rootViewController = self.homeViewController
                }, completion: nil)
            }
        }
    }
}
