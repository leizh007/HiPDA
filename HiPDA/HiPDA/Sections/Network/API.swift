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
        case threads(fid: Int, typeid: Int, page: Int)
        case posts(PostInfo)
        case redirect(String)
        case newThread(fid: Int, typeid: Int, title: String, content: String, formhash: String)
        case formhash(String)
    }
}

extension HiPDA.API: TargetType {
    var baseURL: URL { return URL(string: "https://www.hi-pda.com")! }
    var path: String {
        switch self {
        case .login(_):
            return "/forum/logging.php?action=login&loginsubmit=yes"
        case let .threads(fid: fid, typeid: typeid, page: page):
            return "/forum/forumdisplay.php?fid=\(fid)&filter=type&typeid=\(typeid)&page=\(page)"
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
        case let .newThread(fid: fid, typeid: _, title: _, content: _, formhash: _):
            return "/forum/post.php?action=newthread&fid=\(fid)&extra=&topicsubmit=yes"
        case let .formhash(url):
            return url
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
        case let .newThread(fid: _, typeid: typeid, title: title, content: content, formhash: formhash):
            return [
                "posttime": Int(Date().timeIntervalSince1970),
                "wysiwyg": 1,
                "subject": title,
                "typeid": typeid,
                "message": content,
                "attention_add": 1,
                "formhash": formhash
            ]
        case .formhash(_):
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        return GBKURLEncoding()
    }
    var task: Task {
        return .request
    }
    var sampleData: Data {
        return Data()
    }
}

