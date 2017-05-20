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
        do {
            let retryResult = try Regex.firstMatch(in: html, of: "登录失败，您还可以尝试 (\\d+) 次")
            if retryResult.count == 2 {
                return .nameOrPasswordUnCorrect(timesToRetry: Int(retryResult[1])!)
            }
            if html.range(of: "密码错误次数过多，请 15 分钟后重新登录") != nil {
                return .attempCountExceedsLimit
            }
            return .unKnown("未知错误")
        } catch {
            return LoginError.unKnown("\(error)")
        }
    }
    
    /// 获取登录成功的用户名
    ///
    /// - parameter html: html字符串
    ///
    /// - throws: 异常：HtmlParserError
    ///
    /// - returns: 返回登录成功的用户名
    static func loggedInUserName(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "欢迎您回来，([\\s\\S]*?)。")
        guard result.count == 2 else {
            throw HtmlParserError.cannotGetUsername
        }
        
        return result[1]
    }
    
    /// 用户是否处于激活状态
    ///
    /// - Parameter html: html字符串
    /// - Returns: 是否激活
    static func isLoggedInAccountActived(from html: String) -> Bool {
        return !html.contains("您的帐号处于非激活状态，现在将转入控制面板。")
    }
    
    /// 获取登录结果
    ///
    /// - parameter name: 待登录的账户名
    ///
    /// - parameter html: 返回的html结果页面
    ///
    /// - throws: 异常: LoginError
    ///
    /// - returns: 成功返回解析出来的uid，否则抛出异常
    static func loginResult(of name: String, from html: String) throws -> Int {
        if let username = try? loggedInUserName(from: html) {
            guard username == name else {
                throw LoginError.alreadyLoggedInAnotherAccount(username)
            }
            guard isLoggedInAccountActived(from: html) else {
                throw LoginError.unActived
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
    
    /// 帖子列表
    ///
    /// - Parameter html: html字符串
    /// - Returns: 帖子列表
    /// - Throws: 解析失败的错误信息
    static func threads(from html: String) throws -> [HiPDAThread] {
        enum HiPDAThreadPropertyIndex: Int {
            case id = 1
            case title
            case attachment
            case uid
            case username
            case postTime
            case replyCount
            case readCount
            case totalNumber
        }
        let results = try Regex.matches(in: html, of: "<tbody\\s*id=\\\"normalthread_\\d+\\\">[\\s\\S]*?<span\\s*id=\\\"thread_\\d+\\\">[^v]+viewthread\\.php\\?tid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>([\\s\\S]*?)<td\\s*class=\\\"author\\\">[\\s\\S]*?space\\.php\\?uid=(\\d+)\\\">([\\s\\S]*?)<\\/a>[\\s\\S]*?<em>([^<]+)<\\/em>[\\s\\S]*?<strong>(\\d+)<\\/strong>\\/<em>(\\d+)<\\/em>")
        
        return try results.map { result in
            guard result.count == HiPDAThreadPropertyIndex.totalNumber.rawValue else {
                throw HtmlParserError.unKnown("获取帖子信息失败")
            }
            guard let tid = Int(result[HiPDAThreadPropertyIndex.id.rawValue]) else {
                throw HtmlParserError.unKnown("获取帖子id失败")
            }
            guard let uid = Int(result[HiPDAThreadPropertyIndex.uid.rawValue]) else {
                throw HtmlParserError.unKnown("获取用户id失败")
            }
            guard let replyCount = Int(result[HiPDAThreadPropertyIndex.replyCount.rawValue]) else {
                throw HtmlParserError.unKnown("获取帖子回复数失败")
            }
            guard let readCount = Int(result[HiPDAThreadPropertyIndex.readCount.rawValue]) else {
                throw HtmlParserError.unKnown("获取帖子打开数失败")
            }
            
            return HiPDAThread(id: tid,
                               title: result[HiPDAThreadPropertyIndex.title.rawValue],
                               attachment: HiPDAThreadAttachment.attacthment(from: result[HiPDAThreadPropertyIndex.attachment.rawValue]),
                               user: User(name:result[HiPDAThreadPropertyIndex.username.rawValue], uid:uid),
                               postTime: result[HiPDAThreadPropertyIndex.postTime.rawValue],
                               replyCount: replyCount,
                               readCount: readCount)
        }
    }
    
    /// 总页数
    ///
    /// - Parameter html: html字符串
    /// - Returns: 总页数
    /// - Throws: 解析失败的错误信息
    static func totalPage(from html: String) throws -> Int {
        let result = try Regex.firstMatch(in: html, of: "(\\d+)<\\/a>[^<]*<[^>]+>下一页<\\/a>|<div[^c]*class=\"pages\">[\\s\\S]*?<strong>(\\d+)<\\/strong>[^<]*<\\/div>")
        guard result.count == 3 else { return 1 }
        let pageNumberString = result[1].isEmpty ? result[2] : result[1]
        return Int(pageNumberString) ?? 1
    }
    
    /// 获取帖子主题
    ///
    /// - Parameter html: html字符串
    /// - Returns: 帖子主题
    /// - Throws: 解析失败的错误信息
    static func postTitle(from html: String) throws -> String {
        if html.contains("指定的主题不存在或已被删除或正在被审核，请返回。") {
            throw HtmlParserError.unKnown("指定的主题不存在或已被删除或正在被审核，请返回。")
        }
        let result = try Regex.firstMatch(in: html, of: "<div\\s+id=\\\"threadtitle\\\">[^<]*<h1>(<a[^>]+>[^<]*<\\/a>)?([\\s\\S]*?)<\\/h1>")
        guard result.count == 3 else {
            throw HtmlParserError.unKnown("获取帖子主题失败")
        }
        return result[2]
    }
    
    /// 获取帖子详情列表
    ///
    /// - Parameter html: html字符串
    /// - Returns: 帖子详情列表
    /// - Throws: 解析失败的错误信息
    static func posts(from html: String) throws -> [Post] {
        enum PostPropertyIndex: Int {
            case id = 1
            case uid
            case username
            case floor
            case time
            case content
            case totalNumber
        }
        let results = try Regex.matches(in: html, of: "<div\\s+id=\\\"post_(\\d+)\\\">[\\s\\S]*?<div\\s+class=\\\"postinfo\\\">[^<]*<a[^h]+href=\"space\\.php\\?uid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[\\s\\S]*?<em>(\\d+)<\\/em><sup>#<\\/sup>[\\s\\S]*?发表于\\s+([^<]+)<\\/em>[\\s\\S]*?<div\\s*class=\\\"postmessage[^>]+>([\\s\\S]*?)<td\\s*class=\\\"postcontent\\s*postbottom")
        return try results.map { result in
            guard result.count == PostPropertyIndex.totalNumber.rawValue else {
                throw HtmlParserError.unKnown("获取帖子详情列表失败")
            }
            guard let pid = Int(result[PostPropertyIndex.id.rawValue]) else {
                throw HtmlParserError.unKnown("获取帖子id失败")
            }
            guard let uid = Int(result[PostPropertyIndex.uid.rawValue]) else {
                throw HtmlParserError.unKnown("获取用户id失败")
            }
            guard let floor = Int(result[PostPropertyIndex.floor.rawValue]) else {
                throw HtmlParserError.unKnown("获取帖子楼层数失败")
            }
            let username = result[PostPropertyIndex.username.rawValue]
            
            return Post(id: pid,
                        user: User(name:username, uid:uid),
                        time: result[PostPropertyIndex.time.rawValue],
                        floor: floor,
                        content: result[PostPropertyIndex.content.rawValue])
        }
    }
}
