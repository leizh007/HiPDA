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
        if let account = Settings.shared.lastLoggedInAccount {
            LoginViewModel.login(with: account)
                .subscribe(onNext: { result in
                    EventBus.shared.dispatch(ChangeAccountAction(account: result))
            }).addDisposableTo(disposeBag)
        } else {
            changeRootViewControllerToLogin(withAnimation: false, duration: 0.0, delay: 0.0)
        }
        observeEventBus()
    }
    
    /// 订阅eventBus
    fileprivate func observeEventBus() {
        EventBus.shared.activeAccount
            .do(onNext: { [weak self] loginResult in
                guard let loginResult = loginResult, case .success(_) = loginResult else {
                    self?.changeRootViewControllerToLogin(withAnimation: true, duration: 0.75, delay: 1.0)
                    return
                }
            })
            .drive(Settings.shared.rx.activeAccount)
            .disposed(by: disposeBag)
    }
    
    /// 将rootViewController切换到登录的ViewController
    ///
    /// - Parameters:
    ///   - withAnimation: 是否有动画
    ///   - duration: 动画持续时间
    ///   - seconds: 延迟时间
    private func changeRootViewControllerToLogin(withAnimation: Bool, duration: Double, delay seconds: Double) {
        let loginViewController = LoginViewController.load(from: .login)
        guard let window = UIApplication.shared.windows.safe[0] else { return }
        homeViewController = window.rootViewController
        homeViewController?.view.layoutIfNeeded()
        loginViewController.view.frame = window.bounds
        if withAnimation {
            delay(seconds: seconds) {
                UIView.transition(with: window, duration: duration, options: [.transitionFlipFromLeft, .curveEaseInOut], animations: {
                    window.rootViewController = loginViewController
                }, completion: nil)
            }
        } else {
            window.rootViewController = loginViewController
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
