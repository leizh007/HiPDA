//
//  HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import Moya

extension HiPDA {
    enum API {
        case login(Account)
        case threads(fid: Int, typeid: Int, page: Int, order: ThreadOrder)
        case posts(PostInfo)
        case redirect(String)
        case newThread(fid: Int, typeid: Int, title: String, content: String, formhash: String, imageNumbers: [Int])
        case formhash(String)
        case replyPost(fid: Int, tid: Int, content: String, formhash: String, imageNumbers: [Int])
        case html(String)
        case replyAuthor(fid: Int, tid: Int, pid: Int, formhash: String, noticeauthor: String, noticetrimstr: String, noticeauthormsg: String, content: String, imageNumbers: [Int])
        case quoteAuthor(fid: Int, tid: Int, pid: Int, formhash: String, noticeauthor: String, noticetrimstr: String, noticeauthormsg: String, content: String, imageNumbers: [Int])
        case addToFavorites(tid: Int)
        case addToAttentions(tid: Int)
        case uploadImage(hash: String, data: Data, mimeType: String)
        case userProfile(uid: Int)
        case addFriend(uid: Int)
        case sendShortMessage(username: String, message: String, formhash: String)
        case searchUserThreads(searchId: Int, page: Int)
        case friendMessage(page: Int)
        case threadMessage(page: Int)
        // 私人消息列表
        case privateMessage(page: Int)
        // 私人消息对话
        case privateMessageConversation(uid: Int)
        case replypm(uid: Int, formhash: String, lastdaterange: String, message: String)
        case search(type: SearchType, text: String, page: Int)
        case favorites(page: Int)
        case attention(page: Int)
        case deleteFavorites(tids: [Int], formhash: String)
        case deleteAttentions(tids: [Int], formhash: String)
        case myTopics(page: Int)
        case myPosts(page: Int)
    }
}

extension HiPDA.API: TargetType {
    var baseURL: URL { return URL(string: "https://www.hi-pda.com")! }
    var path: String {
        switch self {
        case .login(_):
            return "/forum/logging.php?action=login&loginsubmit=yes"
        case let .threads(fid: fid, typeid: typeid, page: page, order: order):
            return "/forum/forumdisplay.php?fid=\(fid)&filter=type&typeid=\(typeid)&page=\(page)&orderby=\(order.rawValue)"
        case let .posts(postInfo):
            switch (postInfo.pid, postInfo.authorid) {
            case let (pid?, nil):
                return "/forum/viewthread.php?tid=\(postInfo.tid)&rpid=\(pid)&ordertype=0&page=\(postInfo.page)#pid\(pid)"
            case let (nil, authorid?):
                return "/forum/viewthread.php?tid=\(postInfo.tid)&page=\(postInfo.page)&authorid=\(authorid)"
            default:
                return "/forum/viewthread.php?tid=\(postInfo.tid)&extra=page%3D1&page=\(postInfo.page)"
            }
        case let .redirect(url):
            return url
        case let .newThread(fid: fid, typeid: _, title: _, content: _, formhash: _, imageNumbers: _):
            return "/forum/post.php?action=newthread&fid=\(fid)&extra=&topicsubmit=yes"
        case let .formhash(urlPath):
            return urlPath
        case let .replyPost(fid: fid, tid: tid, content: _, formhash: _, imageNumbers: _):
            return "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)&extra=&replysubmit=yes"
        case let .html(urlPath):
            return urlPath
        case let .replyAuthor(fid: fid, tid: tid, pid: pid, formhash: _, noticeauthor: _, noticetrimstr: _, noticeauthormsg: _, content: _, imageNumbers: _):
            return "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)&reppost=\(pid)&extra=page%3D1&replysubmit=yes"
        case let .quoteAuthor(fid: fid, tid: tid, pid: pid, formhash: _, noticeauthor: _, noticetrimstr: _, noticeauthormsg: _, content: _, imageNumbers: _):
            return "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)&repquote=\(pid)&extra=page%3D1&replysubmit=yes"
        case let .addToFavorites(tid: tid):
            return "/forum/my.php?item=favorites&tid=\(tid)&inajax=1&ajaxtarget=favorite_msg"
        case let .addToAttentions(tid: tid):
            return "/forum/my.php?item=attention&action=add&tid=\(tid)&inajax=1&ajaxtarget=favorite_msg"
        case .uploadImage(_):
            return "/forum/misc.php?type=image&action=swfupload&operation=upload"
        case let .userProfile(uid: uid):
            return "/forum/space.php?uid=\(uid)"
        case let .addFriend(uid: uid):
            return "/forum/my.php?item=buddylist&newbuddyid=\(uid)&buddysubmit=yes&inajax=1&ajaxtarget=addbuddy_menu_content"
        case .sendShortMessage(_):
            return "/forum/pm.php?action=send&pmsubmit=yes&infloat=yes&sendnew=yes"
        case let .searchUserThreads(searchId: searchId, page: page):
            return "/forum/search.php?searchid=\(searchId)&orderby=dateline&ascdesc=desc&searchsubmit=yes&page=\(page)"
        case let .friendMessage(page: page):
            return "/forum/notice.php?filter=friend&page=\(page)"
        case let .threadMessage(page: page):
            return "/forum/notice.php?filter=threads&page=\(page)"
        case let .privateMessage(page: page):
            return "/forum/pm.php?filter=privatepm&page=\(page)"
        case let .privateMessageConversation(uid: uid):
            return "/forum/pm.php?uid=\(uid)&filter=privatepm&daterange=5#new"
        case let .replypm(uid: uid, formhash: _, lastdaterange: _, message: _):
            return "/forum/pm.php?action=send&uid=\(uid)&pmsubmit=yes&infloat=yes&inajax=1"
        case let .search(type: type, text: text, page: page):
            return "/forum/search.php?srchtype=\(type.description)&srchtxt=\(text.gbkEscaped)&searchsubmit=true&st=on&srchuname=&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&page=\(page)"
        case let .favorites(page: page):
            return "/forum/my.php?item=favorites&type=thread&page=\(page)"
        case let .attention(page: page):
            return "/forum/my.php?item=attention&type=thread&page=\(page)"
        case .deleteFavorites(_):
            return "/forum/my.php?item=favorites&type=thread"
        case .deleteAttentions(_):
            return "/forum/my.php?item=attention&type=thread"
        case let .myTopics(page: page):
            return "/forum/my.php?item=threads&page=\(page)"
        case let .myPosts(page: page):
            return "/forum/my.php?item=posts&page=\(page)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .login(_):
            return .post
        case .threads(_):
            return .get
        case .posts(_):
            return .get
        case .redirect(_):
            return .get
        case .newThread(_):
            return .post
        case .formhash(_):
            return .get
        case .replyPost(_):
            return .post
        case .html(_):
            return .get
        case .replyAuthor(_):
            return .post
        case .quoteAuthor(_):
            return .post
        case .addToFavorites(_):
            return .get
        case .addToAttentions(_):
            return .get
        case .uploadImage(_):
            return .post
        case .userProfile(_):
            return .post
        case .addFriend(_):
            return .get
        case .sendShortMessage(_):
            return .post
        case .searchUserThreads(_):
            return .get
        case .friendMessage(_):
            return .get
        case .threadMessage(_):
            return .get
        case .privateMessage(_):
            return .get
        case .privateMessageConversation(_):
            return .get
        case .replypm(_):
            return .post
        case .search(_):
            return .get
        case .favorites(_):
            return .get
        case .attention(_):
            return .get
        case .deleteAttentions(_):
            return .post
        case .deleteFavorites(_):
            return .post
        case .myTopics(_):
            return .get
        case .myPosts(_):
            return .get
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .login(let account):
            return [
                "loginfield": "username",
                "username": account.name,
                "password": account.password,
                "questionid": account.questionid,
                "answer": account.answer,
                "cookietime" : 60 * 60 * 24 * 30
            ]
        case .threads(_):
            return nil
        case .posts(_):
            return nil
        case .redirect(_):
            return nil
        case let .newThread(fid: _, typeid: typeid, title: title, content: content, formhash: formhash, imageNumbers: imageNumbers):
            return update(dic: [
                "posttime": Int(Date().timeIntervalSince1970),
                "wysiwyg": 1,
                "subject": title,
                "typeid": typeid,
                "message": content,
                "attention_add": 1,
                "formhash": formhash
                ], with: imageNumbers)
        case .formhash(_):
            return nil
        case let .replyPost(fid: _, tid: _, content: content, formhash: formhash, imageNumbers: imageNumbers):
            return update(dic: [
                "formhash": formhash,
                "posttime": Int(Date().timeIntervalSince1970),
                "wysiwyg": 1,
                "message": content
                ], with: imageNumbers)
        case .html(_):
            return nil
        case let .replyAuthor(fid: _, tid: _, pid: _, formhash: formhash, noticeauthor: noticeauthor, noticetrimstr: noticetrimstr, noticeauthormsg: noticeauthormsg, content: content, imageNumbers: imageNumbers):
            return update(dic: [
                "formhash": formhash,
                "posttime": Int(Date().timeIntervalSince1970),
                "wysiwyg": 1,
                "noticeauthor": noticeauthor,
                "noticetrimstr": noticetrimstr,
                "noticeauthormsg": noticeauthormsg,
                "subject": "",
                "message": content
                ], with: imageNumbers)
        case let .quoteAuthor(fid: _, tid: _, pid: _, formhash: formhash, noticeauthor: noticeauthor, noticetrimstr: noticetrimstr, noticeauthormsg: noticeauthormsg, content: content, imageNumbers: imageNumbers):
            return update(dic: [
                "formhash": formhash,
                "posttime": Int(Date().timeIntervalSince1970),
                "wysiwyg": 1,
                "noticeauthor": noticeauthor,
                "noticetrimstr": noticetrimstr,
                "noticeauthormsg": noticeauthormsg,
                "subject": "",
                "message": content
                ], with: imageNumbers)
        case .addToFavorites(_):
            return nil
        case .addToAttentions(_):
            return nil
        case .uploadImage(_):
            return nil
        case .userProfile(_):
            return nil
        case .addFriend(_):
            return nil
        case let .sendShortMessage(username: username, message: message, formhash: formhash):
            return [
                "formhash": formhash,
                "msgto": username,
                "message": message,
                "pmsubmit": true
            ]
        case .searchUserThreads(_):
            return nil
        case .friendMessage(_):
            return nil
        case .threadMessage(_):
            return nil
        case .privateMessage(_):
            return nil
        case .privateMessageConversation(_):
            return nil
        case let .replypm(uid: _, formhash: formhash, lastdaterange: lastdaterange, message: message):
            return [
                "formhash": formhash,
                "handlekey": "pmreply",
                "lastdaterange": lastdaterange,
                "message": message
            ]
        case .search(_):
            return nil
        case .favorites(_):
            return nil
        case .attention(_):
            return nil
        case .deleteFavorites(_):
            return nil
        case .deleteAttentions(_):
            return nil
        case .myTopics(_):
            return nil
        case .myPosts(_):
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        return GBKURLEncoding()
    }
    var task: Task {
        switch self {
        case let .uploadImage(hash: hash, data: data, mimeType: mimeType):
            var uid = Settings.shared.activeAccount?.uid ?? 0
            let uidData = "\(uid)".data(using: .utf8) ?? Data(bytes: &uid, count: 1)
            let hashData = hash.data(using: .utf8) ?? Data()
            let suffix = mimeType.substring(from: mimeType.index(after: (mimeType.range(of: "/")?.lowerBound ?? mimeType.startIndex)))
            return .upload(.multipart([MultipartFormData(provider: .data(hashData), name: "hash"),
                                       MultipartFormData(provider: .data(uidData), name: "uid"),
                                       MultipartFormData(provider: .data(data), name: "Filedata", fileName: "HiPDA-image.\(suffix)", mimeType: mimeType)]))
        case let .deleteFavorites(tids: tids, formhash: formhash):
            var tidsData = tids.map { MultipartFormData(provider: .data("\($0)".data(using: .utf8) ?? Data()), name: "delete[]") }
            tidsData.append(MultipartFormData(provider: .data(formhash.data(using: .utf8) ?? Data()), name: "formhash"))
            tidsData.append(MultipartFormData(provider: .data("true".data(using: .utf8) ?? Data()), name: "favsubmit"))
            return .upload(.multipart(tidsData))
        case let .deleteAttentions(tids: tids, formhash: formhash):
            var tidsData = tids.map { MultipartFormData(provider: .data("\($0)".data(using: .utf8) ?? Data()), name: "delete[]") }
            tidsData.append(MultipartFormData(provider: .data(formhash.data(using: .utf8) ?? Data()), name: "formhash"))
            tidsData.append(MultipartFormData(provider: .data("true".data(using: .utf8) ?? Data()), name: "attentionsubmit"))
            return .upload(.multipart(tidsData))
        default:
            return .request
        }
    }
    var sampleData: Data {
        return Data()
    }
}

// MARK: - Utilities

private func update(dic: [String: Any], with imageNumbers: [Int]) -> [String: Any] {
    var dic = dic
    for num in imageNumbers {
        dic["attachnew[\(num)][description]"] = ""
    }
    return dic
}
