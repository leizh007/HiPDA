//
//  HtmlParser.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// Html解析
struct HtmlParser {
    /// 从字符串中获取uid
    ///
    /// - parameter html: html字符串
    ///
    /// - throws: 异常
    ///
    /// - returns: 返回字符串
    static func uid(from html: String) throws -> Int {
        let result = try Regex.firstMatch(in: html, of: "uid=(\\d+)")
        guard result.count == 2, let uid = Int(result[1]) else {
            throw HtmlParserError.cannotGetUid
        }
        
        return uid
    }
    
    /// 获取登录失败信息
    ///
    /// - parameter html: html字符串
    ///
    /// - returns: 失败信息
    static func loginError(from html: String) -> LoginError {
        if let loginFailedStartIndex = html.range(of: "登录失败，您还可以尝试 ") {
            let subHtml = html.substring(from: loginFailedStartIndex.upperBound)
            guard let loginFailedEndIndex = subHtml.range(of: " 次"),
                let retryCount = Int(subHtml.substring(to: loginFailedEndIndex.lowerBound)) else {
                return .unKnown("未知错误")
            }
            return .nameOrPasswordUnCorrect(timesToRetry: retryCount)
        } else {
            return .attempCountExceedsLimit
        }
    }
    
    static func loggedInUserName(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "欢迎您回来，([\\s\\S]*?)。现在将转入登录前页面。")
        guard result.count == 2 else {
            throw HtmlParserError.cannotGetUsername
        }
        
        return result[1]
    }
    
    /// 获取登录结果
    ///
    /// - parameter name: 待登录的账户名
    ///
    /// - parameter html: 返回的html结果页面
    ///
    /// - throws: 异常: LoginError
    ///
    /// - returns: 成功返回解析出来的uid，否则抛出一场
    static func loginResult(of name: String, from html: String) throws -> Int {
        if let username = try? loggedInUserName(from: html) {
            guard username == name else {
                throw LoginError.alreadyLoggedInAnotherAccount(username)
            }
            do {
                let uid = try HtmlParser.uid(from: html)
                return uid
            } catch {
                throw LoginError.unKnown("\(error)")
            }
        } else {
            throw HtmlParser.loginError(from: html)
        }
    }
}
