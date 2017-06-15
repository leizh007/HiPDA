//
//  LoginResult.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 登录失败的错误信息
///
/// - nameOrPasswordUnCorrect: 密码或用户名不正确
/// - attempCountExceedsLimit: 失败次数过多
/// - unKown:                  未知错误
/// - cannotGetUid:            无法获取uid
enum LoginError: Error {
    case nameOrPasswordUnCorrect(timesToRetry: Int)
    case attempCountExceedsLimit
    case unKnown(String)
    case cannotGetUid
    case unActived
    case alreadyLoggedInAnotherAccount(String)
}

extension LoginError: Equatable {
    static func ==(lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
        case (.nameOrPasswordUnCorrect(let value1), .nameOrPasswordUnCorrect(let value2)):
            return value1 == value2
        case (.attempCountExceedsLimit, .attempCountExceedsLimit):
            return true
        case (.unKnown(let value1), .unKnown(let value2)):
            return value1 == value2
        case (.cannotGetUid, .cannotGetUid):
            return true
        case (.unActived, .unActived):
            return true
        case (.alreadyLoggedInAnotherAccount(let value1), .alreadyLoggedInAnotherAccount(let value2)):
            return value1 == value2
        default:
            return false
        }
    }
}

extension LoginError: CustomStringConvertible {
    var description: String {
        switch self {
        case .nameOrPasswordUnCorrect(timesToRetry: let count):
            return "登录失败，您还可以尝试 \(count) 次"
        case .attempCountExceedsLimit:
            return "密码错误次数过多，请 15 分钟后重新登录"
        case .unKnown(let value):
            return value
        case .cannotGetUid:
            return "无法获取uid"
        case .unActived:
            return "您的帐号处于非激活状态，只有激活后才能使用该App！"
        case .alreadyLoggedInAnotherAccount(let name):
            return "已登陆其他账户：\(name), 请清理cookie后再试"
        }
    }
}

extension LoginError: LocalizedError {
    var errorDescription: String? {
        return description
    }
}

typealias LoginResult = HiPDA.Result<Account, LoginError>
