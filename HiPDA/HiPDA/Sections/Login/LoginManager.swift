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
    func bootstrap(bootstrapped: Bootstrapped) throws {
        if let _ = Settings.shared.activeAccount {
            
        } else {
            //let loginViewController = LoginViewController.load(from: UIStoryboard.main)
            //guard let window = UIApplication.shared.windows.safe[0] else { return }
            //window.rootViewController = loginViewController
        }
    }
}
