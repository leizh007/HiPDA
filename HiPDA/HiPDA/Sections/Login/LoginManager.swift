//
//  LoginManager.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

/// 登录管理
class LoginManager: Bootstrapping {
    /// 主页
    private var homeViewController: UIViewController?
    
    /// disposeBag
    private var disposeBag = DisposeBag()
    
    func bootstrap(bootstrapped: Bootstrapped) throws {
        if let account = Settings.shared.activeAccount {
            LoginViewModel.login(with: account)
                .subscribe(onNext: { [weak self] (result) in
                    if case .failure(_) = result {
                        self?.changeRootViewControllerToLogin(duration: 0.75, delay: 1.0)
                    }
                    EventBus.shared.dispatch(ChangeAccountAction(account: result))
            }).addDisposableTo(disposeBag)
        } else {
            changeRootViewControllerToLogin(duration: 0.0, delay: 0.0)
        }
    }
    
    /// 将rootViewController切换到登录的ViewController
    ///
    /// - Parameters:
    ///   - duration: 动画持续时间
    ///   - seconds: 延迟时间
    private func changeRootViewControllerToLogin(duration: Double, delay seconds: Double) {
        let loginViewController = LoginViewController.load(from: .login)
        guard let window = UIApplication.shared.windows.safe[0] else { return }
        homeViewController = window.rootViewController
        homeViewController?.view.layoutIfNeeded()
        loginViewController.view.frame = window.bounds
        delay(seconds: seconds) {
            UIView.transition(with: window, duration: duration, options: [.transitionFlipFromLeft, .curveEaseInOut], animations: {
                window.rootViewController = loginViewController
            }, completion: nil)
        }
        
        loginViewController.loggedInCompletion = { [weak self] account in
            guard let `self` = self else { return }
            Settings.shared.add(account: account)
            Settings.shared.activeAccount = account
            EventBus.shared.dispatch(ChangeAccountAction(account: .success(account)))
            
            guard let window = UIApplication.shared.windows.safe[0] else { return }
            UIView.transition(with: window, duration: 0.75, options: [.transitionFlipFromRight, .curveEaseInOut], animations: {
                window.rootViewController = self.homeViewController
            }, completion:nil)
        }
    }
}
