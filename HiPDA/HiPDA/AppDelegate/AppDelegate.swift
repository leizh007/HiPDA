//
//  AppDelegate.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /// 待启动组件数组
    let bootstrappingComponents: [Bootstrapping] = [
        CrashAnalysis(),
        LoginManager()
    ]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = C.Color.navigationBarTintColor
        bootstrap()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Settings.shared.save()
    }
}

// MARK: - 启动相关

extension AppDelegate {
    /// 启动
    func bootstrap() {
        do {
            try bootstrapped(components: bootstrappingComponents)
        } catch {
            assertionFailure("组件启动失败！")
        }
    }

    /// 启动组件
    ///
    /// - parameter components: 组件数组
    ///
    /// - throws: 启动失败抛出异常
    ///
    /// - returns: 启动成功返回Bootstrapped类型的实例
    @discardableResult
    func bootstrapped(components: [Bootstrapping]) throws -> Bootstrapped {
        return try components.reduce(Bootstrapped(), { (bootstrapped, next) -> Bootstrapped in
            return try bootstrapped.bootstrap(component: next)
        })
    }
}
