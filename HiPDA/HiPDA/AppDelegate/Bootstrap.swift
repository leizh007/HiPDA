//
//  Bootstrap.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/2.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 启动错误信息
///
/// - ExpectedComponentNotFound: 组件未找到
enum BootstrappingError: Error {
    case ExpectedComponentNotFound(String)
}

/// 可启动接口
protocol Bootstrapping {
    
    /// 调用该函数启动组件
    ///
    /// - parameter bootstrapped: Bootstrapped实例
    ///
    /// - throws: 启动失败抛出异常
    func bootstrap(bootstrapped: Bootstrapped) throws
}


/// 管理已启动组件的信息
struct Bootstrapped {
    private let bootstrappedComponents: [Bootstrapping]
    
    init() {
        bootstrappedComponents = []
    }
    
    init(_ bootstrappedComponents: [Bootstrapping]) {
        self.bootstrappedComponents = bootstrappedComponents
    }
    
    /// 启动组件
    ///
    /// - parameter component: 待启动的组件
    ///
    /// - throws: 启动失败抛出异常
    ///
    /// - returns: 返回新的Bootstrapped实例对象
    func bootstrap(component: Bootstrapping) throws -> Bootstrapped {
        try component.bootstrap(bootstrapped: self)
        
        var bootstrappedComponents = self.bootstrappedComponents
        bootstrappedComponents.append(component)
        
        return Bootstrapped(bootstrappedComponents)
    }
    
    /// 查找指定类型的组件是否已经启动成功
    ///
    /// - parameter type: 组件类型
    ///
    /// - throws: 查找失败抛出异常
    ///
    /// - returns: 返回查找成功的值
    func component<T: Bootstrapping>(type: T.Type) throws -> T {
        guard  let component = bootstrappedComponents.first(where: { $0 is T }) as? T else {
            throw BootstrappingError.ExpectedComponentNotFound("\(T.self)")
        }
        
        return component
    }
}
