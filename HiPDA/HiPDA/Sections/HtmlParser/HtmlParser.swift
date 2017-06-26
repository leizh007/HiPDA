//
//  HtmlParser.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

struct HtmlParser {
    static func uid(from html: String) throws -> Int {
        let result = try Regex.firstMatch(in: html, of: "uid=(\\d+)")
        guard result.count == 2, let uid = Int(result[1]) else {
            throw HtmlParserError.cannotGetUid
        }
        
        return uid
    }
    
    static func loggedInUserName(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "欢迎您回来，([\\s\\S]*?)。")
        guard result.count == 2 else {
            throw HtmlParserError.cannotGetUsername
        }
        
        return result[1]
    }
    
    static func isLoggedInAccountActived(from html: String) -> Bool {
        return !html.contains("您的帐号处于非激活状态，现在将转入控制面板。")
    }
    
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
            throw LoginError.unKnown("未知错误")
        }
    }
    
    static func threads(from html: String) throws -> [HiPDA.Thread] {
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
                throw HtmlParserError.underlying("获取帖子信息失败")
            }
            guard let tid = Int(result[HiPDAThreadPropertyIndex.id.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子id失败")
            }
            guard let uid = Int(result[HiPDAThreadPropertyIndex.uid.rawValue]) else {
                throw HtmlParserError.underlying("获取用户id失败")
            }
            guard let replyCount = Int(result[HiPDAThreadPropertyIndex.replyCount.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子回复数失败")
            }
            guard let readCount = Int(result[HiPDAThreadPropertyIndex.readCount.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子打开数失败")
            }
            
            return HiPDA.Thread(id: tid,
                               title: result[HiPDAThreadPropertyIndex.title.rawValue].stringByDecodingHTMLEntities,
                               attachment: HiPDA.ThreadAttachment.attacthment(from: result[HiPDAThreadPropertyIndex.attachment.rawValue]),
                               user: User(name:result[HiPDAThreadPropertyIndex.username.rawValue], uid:uid),
                               postTime: result[HiPDAThreadPropertyIndex.postTime.rawValue],
                               replyCount: replyCount,
                               readCount: readCount)
        }
    }
    
    static func totalPage(from html: String) throws -> Int {
        let result1 = try Regex.firstMatch(in: html, of: "(\\d+)<\\/a>[^<]*<[^>]+>下一页<\\/a>")
        if result1.count == 2 {
            return Int(result1[1]) ?? 1
        }
        let result2 = try Regex.firstMatch(in: html, of: "<div[^c]*class=\"pages\">[\\s\\S]*?<strong>(\\d+)<\\/strong>[^<]*<\\/div>")
        if result2.count == 2 {
            return Int(result2[1]) ?? 1
        }
        
        return 1
    }
    
    static func postTitle(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "<div\\s+id=\\\"threadtitle\\\">[^<]*<h1>(<a[^>]+>[^<]*<\\/a>)?([\\s\\S]*?)<\\/h1>")
        guard result.count == 3 else {
            throw HtmlParserError.underlying("获取帖子主题失败")
        }
        return result[2]
    }
    
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
                throw HtmlParserError.underlying("获取帖子详情列表失败")
            }
            guard let pid = Int(result[PostPropertyIndex.id.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子id失败")
            }
            guard let uid = Int(result[PostPropertyIndex.uid.rawValue]) else {
                throw HtmlParserError.underlying("获取用户id失败")
            }
            guard let floor = Int(result[PostPropertyIndex.floor.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子楼层数失败")
            }
            let username = result[PostPropertyIndex.username.rawValue]
            
            return Post(id: pid,
                        user: User(name:username, uid:uid),
                        time: result[PostPropertyIndex.time.rawValue],
                        floor: floor,
                        content: result[PostPropertyIndex.content.rawValue])
        }
    }
    
    static func formhash(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "formhash=(\\w+)")
        guard result.count == 2, !result[1].isEmpty else {
            throw HtmlParserError.underlying("获取formhash失败")
        }
        return result[1]
    }
    
    static func tid(from html: String) throws -> Int {
        let result = try Regex.firstMatch(in: html, of: "tid=(\\d+)")
        guard result.count == 2, let tid = Int(result[1]) else {
            throw HtmlParserError.underlying("获取postnum失败")
        }
        return tid
    }
    
    static func alertInfo(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "<div\\s+class=\\\"postbox\\\"><div\\s+class=\\\"alert_\\w+\\\">[^<]*<p>([^<]+)<\\/p>")
        if result.count == 2 && !result[1].isEmpty {
            return result[1]
        }
        let result2 = try Regex.firstMatch(in: html, of: "<div\\s+class=\\\"postbox\\\"><div\\s+class=\\\"alert_\\w+\\\">[^<]*<p>([^<]+)<script>")
        guard result2.count == 2, !result2[1].isEmpty else {
            throw HtmlParserError.underlying("获取提示信息失败")
        }
        
        return result2[1]
    }
    
    static func fid(from html: String) throws -> Int {
        let result = try Regex.firstMatch(in: html, of: "post\\.php\\?action=newthread&fid=(\\d+)")
        guard result.count == 2, let fid = Int(result[1]) else {
            throw HtmlParserError.underlying("获取fid失败")
        }
        return fid
    }
    
    static func hash(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "name=\\\"hash\\\"\\s+value=\\\"([^\\\"]+)\\\"")
        guard result.count == 2 && !result[1].isEmpty else {
            throw HtmlParserError.underlying("获取hash失败")
        }
        return result[1]
    }
    
    static func replyValue(for key: String, in html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "name=\\\"\(key)\\\"[\\s\\S]*?value=\\\"([\\s\\S]*?)\\\"\\s+\\/>")
        guard result.count == 2 else {
            throw NewThreadError.underlying("无法获取\(key)")
        }
        return result[1].trimmingCharacters(in: CharacterSet(charactersIn: "\n "))
    }
    
    static func attachImageNumber(from html: String) throws -> Int {
        if let num = Int(html) {
            return num
        }
        let result = try Regex.firstMatch(in: html, of: "DISCUZUPLOAD|\\d+|(\\d+)|\\d+")
        guard result.count == 2 && !result[1].isEmpty, let num = Int(result[1]) else {
            throw NewThreadError.underlying("无法获取图片附件号码")
        }
        return num
    }
    
    static func addFriendPromptInformation(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "<root><!\\[CDATA\\[([^\\]]+)\\]\\]><\\/root>")
        guard result.count == 2 && !result[1].isEmpty else {
            throw HtmlParserError.underlying("获取返回结果出错")
        }
        return result[1]
    }
    
    static func searchId(from urlString: String) throws -> Int {
        let result = try Regex.firstMatch(in: urlString, of: "searchid=(\\d+)")
        guard result.count == 2 && !result[1].isEmpty, let searchId = Int(result[1]) else {
            throw HtmlParserError.underlying("获取用户发表的帖子信息出错")
        }
        return searchId
    }
    
    static func searchUserThreads(from html: String) throws -> [SearchUserThreadModel] {
        enum UserThreadPropertyIndex: Int {
            case id = 1
            case title
            case forumName
            case time
            case replyCount
            case readCount
        }
        let results = try Regex.matches(in: html, of: "<th\\s+class=\"subject\">[\\s\\S]*?<a\\s+href=\"viewthread\\.php\\?tid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[\\s\\S]*?<a\\s+href=\"forumdisplay\\.php\\?fid=\\d+\">([^<]+)<\\/a>[\\s\\S]*?<em>([\\d-]+)<\\/em>[\\s\\S]*?<strong>(\\d+)<\\/strong>[^<]+<em>(\\d+)<\\/em>")
        return try results.map { result in
            guard let tid = Int(result[UserThreadPropertyIndex.id.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子id出错")
            }
            guard let replyCount = Int(result[UserThreadPropertyIndex.replyCount.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子回复数出错")
            }
            guard let readCount = Int(result[UserThreadPropertyIndex.readCount.rawValue]) else {
                throw HtmlParserError.underlying("获取帖子阅读数出错")
            }
            return SearchUserThreadModel(id: tid,
                                         title: result[UserThreadPropertyIndex.title.rawValue].stringByDecodingHTMLEntities,
                                         forumName: result[UserThreadPropertyIndex.forumName.rawValue],
                                         postTime: result[UserThreadPropertyIndex.time.rawValue].descriptionTimeStringForThread,
                                         replyAndReadCount: "\(replyCount)/\(readCount)")
        }
    }
}
