//
//  Result.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 默认的Result类型，Error类型为NSError
typealias DefaultResult<T> = Result<T, NSError>

/// 各种处理的返回结果
///
/// - success: 成功
/// - failure: 失败
enum Result<T, Error: Swift.Error> {
    case success(T)
    case failure(Error)
}

extension Result {
    /// Result的map函数
    ///
    /// - parameter transform: 转换函数
    ///
    /// - throws: 转换过程中的异常
    ///
    /// - returns: 返回转换后的Result实例
    func map<U>(_ transform: (T) throws -> U) rethrows -> Result<U, Error> {
        switch self {
        case .success(let t):
            return try .success(transform(t))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Result的flatMap函数
    ///
    /// - parameter transform: 转换函数
    ///
    /// - throws: 转换过程中的异常
    ///
    /// - returns: 返回转换后的Result实例
    func flatMap<U>(_ transform: (T) throws -> Result<U, Error>) rethrows -> Result<U, Error> {
        switch self {
        case .success(let t):
            return try transform(t)
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Result {
    /// 初始化方法
    ///
    /// - parameter throwingExpr: 传入初始化block
    ///
    /// - returns: 表达式执行成功则构建.success，否则构建.failure
    init(_ throwingExpr: () throws -> T) {
        do {
            let value = try throwingExpr()
            self = .success(value)
        } catch {
            self = .failure(error as! Error)
        }
    }
    
    /// 获取Result内部的结果
    ///
    /// - throws: 如果是.failure抛出异常
    ///
    /// - returns: 如果是.success返回值
    func dematerialize() throws -> T {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

