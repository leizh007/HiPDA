//
//  NewThreadType.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

enum NewThreadType {
    case new(fid: Int)
    case replyPost(fid: Int, tid: Int)
    case replyAuthor(fid: Int, tid: Int, pid: Int)
    case quote(fid: Int, tid: Int, pid: Int)
}

extension NewThreadType {
    var pageURLPath: String {
        switch self {
        case let .new(fid: fid):
            return "/forum/post.php?action=newthread&fid=\(fid)"
        case let .replyPost(fid: fid, tid: tid):
            return "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)"
        case let .replyAuthor(fid: fid, tid: tid, pid: pid):
            return "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)&reppost=\(pid)"
        case let .quote(fid: fid, tid: tid, pid: pid):
            return "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)&repquote=\(pid)&extra=page%3D1"
        }
    }
}

// MARK: - CustomStringConvertible

extension NewThreadType: CustomStringConvertible {
    var description: String {
        switch self {
        case .new(_):
            return "发表新帖"
        case .replyPost(_):
            return "回复"
        case .replyAuthor(_):
            return "回复"
        case .quote:
            return "引用"
        }
    }
}
