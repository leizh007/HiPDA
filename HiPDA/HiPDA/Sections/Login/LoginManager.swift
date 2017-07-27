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
    fileprivate var isInAppLoading = true
    
    /// 主页
    private var homeViewController: UIViewController?
    
    /// disposeBag
    private var disposeBag = DisposeBag()
    
    func bootstrap(bootstrapped: Bootstrapped) throws {
        if let account = Settings.shared.lastLoggedInAccount, Settings.shared.shouldAutoLogin {
            LoginManager.login(with: account).do(onNext: { [weak self] _ in
                self?.isInAppLoading = false
            }).subscribe(onNext: { result in
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
                    self?.changeRootViewControllerToLogin(withAnimation: true, duration: 0.75, delay: 0.0)
                    return
                }
                self?.isInAppLoading = false
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
        loginViewController.view.frame = CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: C.UI.screenHeight)
        loginViewController.view.layoutIfNeeded()
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
            guard let window = UIApplication.shared.windows.safe[0] else { return }
            // FIXME: - 替换为更有效的解决方法
            // http://stackoverflow.com/questions/7167524/xcode-using-a-uiview-transitionfromview-moves-the-views-up
            if self.isInAppLoading {
                self.homeViewController?.view.frame = CGRect(x: 0, y: C.UI.statusBarHeight, width: C.UI.screenWidth, height: C.UI.screenHeight - C.UI.statusBarHeight)
            }
            self.isInAppLoading = false
            Settings.shared.add(account: account)
            Settings.shared.activeAccount = account
            EventBus.shared.dispatch(ChangeAccountAction(account: .success(account)))
            UIView.transition(with: window, duration: 0.75, options: [.transitionFlipFromRight, .curveEaseInOut], animations: {
                window.rootViewController = self.homeViewController
            }, completion:nil)
        }
    }
    
    /// 登录
    ///
    /// - parameter account: 待登录的账户
    ///
    /// - returns: 返回Observable包含登录结果
    static func login(with account: Account) -> Observable<LoginResult> {
        CookieManager.shared.clear()
        if let cookies = CookieManager.shared.cookies(for: account) {
            CookieManager.shared.set(cookies: cookies, for: account)
            return Observable.just(LoginResult.success(account))
        }
        return Observable.create { observer in
            HiPDAProvider.request(.login(account))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .mapGBKString()
                .map {
                    return try HtmlParser.loginResult(of: account.name, from: $0)
                }
                .observeOn(MainScheduler.instance)
                .subscribe { event in
                    switch event {
                    case let .next(uid):
                        observer.onNext(.success(Account.uidLens.set(uid, account)))
                    case let .error(error):
                        observer.onNext(.failure(error is LoginError ? error as! LoginError : .unKnown(error.localizedDescription)))
                    default:
                        break
                    }
                    observer.onCompleted()
            }
        }
    }

}
