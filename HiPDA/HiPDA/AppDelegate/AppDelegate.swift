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
    let bootstrappingComponents = [ CrashAnalysis() ]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        bootstrap()
        return true
    }
}

// MARK: - 启动相关

extension AppDelegate {
    /// 启动
    func bootstrap() {
        do {
            _ = try bootstrapped(components: bootstrappingComponents)
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
    func bootstrapped(components: [Bootstrapping]) throws -> Bootstrapped {
        return try components.reduce(Bootstrapped(), { (bootstrapped, next) -> Bootstrapped in
            return try bootstrapped.bootstrap(component: next)
        })
    }
}
