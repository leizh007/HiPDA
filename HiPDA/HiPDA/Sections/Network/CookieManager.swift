//
//  CookieManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

/// 处理Cookie相关
class CookieManager {
    static let shared = CookieManager()
    private let disposeBag = DisposeBag()
    
    private init() {
        EventBus.shared.activeAccount.asObservable()
            .subscribe(onNext: { [unowned self] loginResult in
                guard let loginResult = loginResult, case .success(let account) = loginResult else {
                    return
                }
                let cookies = self.currentCookies()
                self.set(cookies: cookies, for: account)
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate var cookieCache = [Account: [HTTPCookie]]()
    
    /// 清除所有cookie
    func clear() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
    }
    
    func cookies(for account: Account) -> [HTTPCookie]? {
        return cookieCache[account]
    }
    
    func set(cookies: [HTTPCookie]?, for account: Account) {
        cookieCache[account] = cookies
        clear()
        cookies?.forEach { HTTPCookieStorage.shared.setCookie($0) }
    }
    
    func currentCookies() -> [HTTPCookie]? {
        return HTTPCookieStorage.shared.cookies
    }
}
