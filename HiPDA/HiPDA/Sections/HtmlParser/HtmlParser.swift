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
    
    static func messageCount(of type: String, from html: String) throws -> Int {
        let result = try Regex.firstMatch(in: html, of: "\(type)\\s+\\((\\d+)\\)")
        guard result.count == 2 && !result[1].isEmpty, let count = Int(result[1]) else {
            throw HtmlParserError.underlying("无法获取\(type)")
        }
        return count
    }
    
    static func friendMessages(from html: String) throws -> [FriendMessageModel] {
        let results = try Regex.matches(in: html, of: "<div\\s+class=\"f_buddy\"><a\\s+href=[^&]+&uid=(\\d+)\">([\\s\\S]*?)<\\/a>[^<]+<em>([^<]+)<\\/em>([\\s\\S]*?)<\\/div>")
        return try results.map { result in
            guard let uid = Int(result[1]) else { throw HtmlParserError.underlying("获取用户id出错") }
            guard !result[2].isEmpty else { throw HtmlParserError.underlying("获取用户名出错") }
            guard !result[3].isEmpty else { throw HtmlParserError.underlying("获取消息时间出错") }
            let isRead = !result[4].contains("notice_newpm.gif")
            return FriendMessageModel(isRead: isRead, sender: User(name: result[2], uid: uid), time: result[3])
        }
    }
    
    static func threadMessages(from html: String) throws -> [ThreadMessageModel] {
        let results = try Regex.matches(in: html, of: "<li\\s+class=\"s_clear\">([\\s\\S]*?<\\/a>)\\s([^<]+)<a\\s+href=\"[^\"]+\">([\\s\\S]*?)<\\/a>([\\s\\S]*?)<em>([^<]+)<\\/em>([\\s\\S]*?)<a\\s+href=\"([^\"]+)\"[^>]*>查看")
        return try results.map { result in
            guard !result[1].isEmpty else { throw HtmlParserError.underlying("获取发帖用户名出错") }
            var senderName = result[1] as NSString
            let linkTagRegex = try Regex.regularExpression(of: "<[^>]+>")
            for result in linkTagRegex.matches(in: senderName as String, range: NSRange(location: 0, length: senderName.length)).reversed() {
                senderName = senderName.replacingCharacters(in: result.range, with: "") as NSString
            }
            var action = result[2]
            action = action.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !action.isEmpty else { throw HtmlParserError.underlying("获取用户操作出错") }
            guard !result[7].isEmpty else { throw HtmlParserError.underlying("获取帖子链接出错") }
            guard !result[3].isEmpty else { throw HtmlParserError.underlying("获取帖子主题出错") }
            guard !result[5].isEmpty else { throw HtmlParserError.underlying("获取发表时间出错") }
            let content = result[6]
            let isRead = !content.contains("notice_newpm")
            let contentResult = try Regex.firstMatch(in: content, of: "<dl\\s+class=\"summary\"><dt>您的帖子：<dt><dd>([\\s\\S]*?)<\\/dd><dt>[\\s\\S]*?说：<\\/dt><dd>([\\s\\S]*?)<\\/dd><\\/dl>")
            let yourPost = contentResult.safe[1]?.stringByDecodingHTMLEntities
            let senderPost = contentResult.safe[2]?.stringByDecodingHTMLEntities
            return ThreadMessageModel(isRead: isRead, senderName: senderName as String, action: action, postTitle: result[3], postAction: result[4].trimmingCharacters(in: .whitespacesAndNewlines), postURL: result[7], time: result[5], yourPost: yourPost, senderPost: senderPost)
        }
    }
    
    static func privateMessages(from html: String) throws -> [PrivateMessageModel] {
        let results = try Regex.matches(in: html, of: "<li\\s+id=\"pm_\\d+\"\\s+class=\"s_clear[\\s\\S]*?<cite><a\\s+href=\"space\\.php\\?uid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a><\\/cite>([^<]+)([\\s\\S]*?)<\\/p>[^<]*<div\\s+class=\"summary\">([\\s\\S]*?)<\\/div>[^<]*<p[^<]+<a\\s+href=\"([^\"]+)\"")
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-M-d"
        let today = dateFormater.string(from: date)
        let yesterdayDate = Date(timeInterval: -60 * 60 * 24, since: date)
        let yesterday = dateFormater.string(from: yesterdayDate)
        let theDayBeforeYesterdayDate = Date(timeInterval: -60 * 60 * 24 * 2, since: date)
        let theDayBeforeYesterday = dateFormater.string(from: theDayBeforeYesterdayDate)
        return try results.map { result in
            guard !result[2].isEmpty else { throw HtmlParserError.underlying("获取用户名出错") }
            guard !result[1].isEmpty, let uid = Int(result[1]) else { throw HtmlParserError.underlying("获取用户id出错") }
            guard !result[3].isEmpty else { throw HtmlParserError.underlying("获取消息时间出错") }
            let time = result[3].replacingOccurrences(of: "今天", with: today)
                .replacingOccurrences(of: "昨天", with: yesterday)
                .replacingOccurrences(of: "前天", with: theDayBeforeYesterday)
            let isRead = !result[4].contains("notice_newpm.gif")
            let content = result[5].trimmingCharacters(in: .whitespacesAndNewlines).stringByDecodingHTMLEntities
            let url = "/forum/\(result[6])"
            return PrivateMessageModel(sender: User(name: result[2], uid: uid), time: time, content: content, isRead: isRead, url: url)
        }
    }
    
    static func chatMessges(from html: String) throws -> [ChatMessage] {
        let results = try Regex.matches(in: html, of: "<li\\s+id=\"pm_\\d+\"\\s+class=\"s_clear[^>]+>[\\s\\S]*?<p\\s+class=\"cite\">[^<]*<cite>([\\s\\S]*?)<\\/cite>([\\d-\\s:]+)([\\s\\S]*?)<\\/p>[^<]*<div\\s+class=\"summary\">([\\s\\S]*?)<\\/div>")
        return try results.map { result in
            let name = result[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let time = result[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let isRead = !result[3].contains("notice_newpm.gif")
            var content = result[4].trimmingCharacters(in: .whitespacesAndNewlines).stringByDecodingHTMLEntities
            content = try HtmlParser.mapEmoticonInMessageContent(content)
            return ChatMessage(name: name, time: time, isRead: isRead, content: try HtmlParser.removeHtmlTags(from: content))
        }
    }
    
    private static func removeHtmlTags(from content: String) throws -> String {
        let str = "<a\\s+href=\"([^\"]+)\"[^>]+>[^<]+<\\/a>|<img\\s+src=\"([^\"]+)\"[^\\/]+\\/>"
        let regex = try Regex.regularExpression(of: str)
        var html = content as NSString
        let results = regex.matches(in: html as String, range: NSRange(location: 0, length: html.length))
        for result in results.reversed() {
            let range = result.range
            let str1 = result.rangeAt(1).location == NSNotFound ? "" : html.substring(with: result.rangeAt(1))
            let str2 = result.rangeAt(2).location == NSNotFound ? "" : html.substring(with: result.rangeAt(2))
            if !str1.isEmpty {
                html = html.replacingCharacters(in: range, with: str1) as NSString
            } else if !str2.isEmpty {
                html = html.replacingCharacters(in: range, with: str2) as NSString
            }
        }
        return html.replacingOccurrences(of: "<br />", with: "") as String
    }
    
    private static func mapEmoticonInMessageContent(_ content: String) throws -> String {
        let str = "<img\\s+src=\"[^\"]+smilies\\/(\\w+)\\/([^\\.]+)\\.gif\"[^>]+>"
        let regex = try Regex.regularExpression(of: str)
        var html = content as NSString
        let results = regex.matches(in: html as String, range: NSRange(location: 0, length: html.length))
        for result in results.reversed() {
            let range = result.range
            let str1 = result.rangeAt(1).location == NSNotFound ? "" : html.substring(with: result.rangeAt(1))
            let str2 = result.rangeAt(2).location == NSNotFound ? "" : html.substring(with: result.rangeAt(2))
            let emoticon = "\(str1)_\(str2)"
            if let code = EmoticonHelper.nameCodeDic[emoticon] {
                html = html.replacingCharacters(in: range, with: code) as NSString
            }
        }
        return html as String
    }
    
    static func searchTitleModels(from html: String) throws -> [SearchTitleModel] {
        let str = "<th\\s+class=\"subject\">([^<]+<){3}a\\s+href=\"viewthread\\.php\\?tid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[\\s\\S]*?forumdisplay\\.php\\?fid=\\d+\">([\\s\\S]*?)<\\/a>[\\s\\S]*?uid=(\\d+)\">([\\s\\S]*?)<\\/a>([^<]+<){2}em>([\\d-]+)<\\/em>([^<]+<){3}strong>(\\d+)<[^<]+<em>(\\d+)<\\/em>"
        let results = try Regex.matches(in: html, of: str)
        return try results.map { result in
            guard result.count == 12 else { throw HtmlParserError.underlying("获取搜索结果出错") }
            guard let tid = Int(result[2]) else { throw HtmlParserError.underlying("获取帖子id出错") }
            let title = result[3]
            let (content: titleContent, ranges: wordRanges) = try HtmlParser.titleContentAndHighlightWordRanges(in: title)
            let forumName = result[4]
            guard let uid = Int(result[5]) else { throw HtmlParserError.underlying("获取用户id出错") }
            let user = User(name: result[6], uid: uid)
            let time = result[8]
            guard let replyCount = Int(result[10]) else { throw HtmlParserError.underlying("获取帖子回复数出错") }
            guard let readCount = Int(result[11]) else { throw HtmlParserError.underlying("获取哦帖子查看数出错") }
            return SearchTitleModel(tid: tid, title: titleContent, titleHighlightWordRanges: wordRanges, forumName: forumName, user: user, time: time, readCount: readCount, replyCount: replyCount)
        }
    }
    
    fileprivate static func titleContentAndHighlightWordRanges(in title: String) throws -> (content: String, ranges: [NSRange]) {
        let title = title as NSString
        let content = NSMutableString()
        var ranges = [NSRange]()
        let str = "<em\\sstyle=\"color:red;\">([\\s\\S]*?)<\\/em>"
        let regex = try Regex.regularExpression(of: str)
        let results = regex.matches(in: title as String, range: NSRange(location: 0, length: title.length))
        var index = 0
        for result in results {
            let contentRange = result.rangeAt(1)
            content.append(title.substring(with: NSRange(location: index, length: result.range.location - index)))
            let range = NSRange(location: content.length, length: contentRange.length)
            ranges.append(range)
            content.append(title.substring(with: contentRange))
            index = result.range.location + result.range.length
        }
        content.append(title.substring(with: NSRange(location: index, length: title.length - index)))
        
        return (content: content as String, ranges: ranges)
    }
    
    static func searchFulltextModels(from html: String) throws -> [SearchFulltextModel] {
        let pattern = "sp_title\">[\\s\\S]*?标题[\\s\\S]*?pid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[^>]+>[^>]+>([\\s\\S]*?)<\\/div>[\\s\\S]*?fid=\\d+\">([\\s\\S]*?)<\\/a>[\\s\\S]*?uid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a><\\/span>[^>]+>查看:\\s+(\\d+)<\\/span>[^>]+>回复:\\s+(\\d+)<\\/span>[^>]+>最后发表:\\s+([\\d-:\\s]+)<\\/span>"
        let results = try Regex.matches(in: html, of: pattern)
        return try results.map { result in
            guard let pid = Int(result[1]) else { throw HtmlParserError.underlying("获取帖子id失败") }
            let title = result[2]
            let (content: content, ranges: wordRanges) = try HtmlParser.titleContentAndHighlightWordRanges(in: result[3])
            let forumName = result[4]
            guard let uid = Int(result[5]) else { throw HtmlParserError.underlying("获取用户id出错") }
            let user = User(name: result[6], uid: uid)
            guard let replyCount = Int(result[8]) else { throw HtmlParserError.underlying("获取帖子回复数出错") }
            guard let readCount = Int(result[7]) else { throw HtmlParserError.underlying("获取哦帖子查看数出错") }
            let time = result[9]
            return SearchFulltextModel(pid: pid, title: title, content: content, contentHighlightWordRanges: wordRanges, forumName: forumName, user: user, readCount: readCount, replyCount: replyCount, time: time)
        }
    }
    
    static func favoriteModels(from html: String) throws -> [FavoritesAndAttentionBaseModel] {
        let pattern = "<tr>[\\s\\S]*?<th>[^\\?]+\\?tid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[^\\?]+\\?[^>]+>([\\s\\S]*?)<\\/a>"
        let results = try Regex.matches(in: html, of: pattern)
        return try results.map { result in
            guard let tid = Int(result[1]) else { throw HtmlParserError.underlying("获取帖子id失败") }
            return FavoritesAndAttentionBaseModel(forumName: result[3], title: result[2], tid: tid)
        }
    }
    
    static func attentionModels(from html: String) throws -> [FavoritesAndAttentionBaseModel] {
        let pattern = "<tr>[\\s\\S]*?<th>[^\\?]+\\?tid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[\\s\\S]*?<td\\s+class=\"forum\">([\\s\\S]*?)<\\/td>"
        let results = try Regex.matches(in: html, of: pattern)
        return try results.map { result in
            guard let tid = Int(result[1]) else { throw HtmlParserError.underlying("获取帖子id失败") }
            return FavoritesAndAttentionBaseModel(forumName: result[3], title: result[2], tid: tid)
        }
    }
    
    static func myTopicModels(from html: String) throws -> [MyTopicModel] {
        let pattern = "<th>[^\\?]+\\?tid=(\\d+)[^>]+>([\\s\\S]*?)<\\/a>[^\\?]+\\?fid=\\d+[^>]+>([\\s\\S]*?)<\\/a>"
        let results = try Regex.matches(in: html, of: pattern)
        return try results.map { result in
            guard let tid = Int(result[1]) else { throw HtmlParserError.underlying("获取帖子id失败") }
            return MyTopicModel(tid: tid, title: result[2].stringByDecodingHTMLEntities, forumName: result[3])
        }
    }
    
    static func myPostModels(from html: String) throws -> [MyPostModel] {
        let pattern = "<th>[^<]*<a\\shref=\"([^\"]+)\"[^>]+>([\\s\\S]*?)<\\/a>([^>]+>){3}([\\s\\S]*?)<\\/a>[\\s\\S]*?<em>([\\d-\\s:]+)<\\/em>[\\s\\S]*?lighttxt\">([\\s\\S]*?)<\\/th>[^<]*<\\/tr>"
        let results = try Regex.matches(in: html, of: pattern)
        return results.map { result in
            return MyPostModel(urlPath: result[1].stringByDecodingHTMLEntities, title: result[2].stringByDecodingHTMLEntities, content: result[6], forumName: result[4], postTime: result[5])
        }
    }
}
