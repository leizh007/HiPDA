//
//  PostRequestInfo.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct PostInfo {
    let tid: Int
    let page: Int
    let pid: Int?
    let authorid: Int?
    
    init(tid: Int, page: Int = 1, pid: Int? = nil, authorid: Int? = nil) {
        self.tid = tid
        self.page = page
        self.pid = pid
        self.authorid = authorid
    }
    
    init?(urlString: String) {
        enum PropertyKeys: String {
            case tid
            case page
            case pid
            case authorid
        }
        guard let index = urlString.range(of: "https://www.hi-pda.com/forum/viewthread.php?")?.upperBound else { return nil }
        var subString = urlString.substring(from: index)
        if let sharpIndex = subString.range(of: "#pid")?.lowerBound {
            subString = subString.substring(to: sharpIndex)
        }
        var dic = [String: Int]()
        for string in subString.components(separatedBy: "&") {
            let attribute = string.components(separatedBy: "=")
            guard attribute.count == 2 else { continue }
            let key = attribute[0]
            guard let value = Int(attribute[1]) else { continue }
            dic[key] = value
        }
        guard let tid = dic[PropertyKeys.tid.rawValue] else { return nil }
        self.tid = tid
        self.page = dic[PropertyKeys.page.rawValue] ?? 1
        self.pid = dic[PropertyKeys.pid.rawValue] ?? dic["rpid"]
        self.authorid = dic[PropertyKeys.authorid.rawValue]
    }
}

// MARK: - Equatable

extension PostInfo: Equatable {
    static func ==(lhs: PostInfo, rhs: PostInfo) -> Bool {
        return lhs.tid == rhs.tid &&
        lhs.page == rhs.page &&
        lhs.pid == rhs.pid &&
        lhs.authorid == rhs.authorid
    }
}

// MARK: - Lens

extension PostInfo {
    enum lens {
        static let page = Lens<PostInfo, Int>(get: { $0.page }, set: { return PostInfo(tid: $1.tid, page: $0, pid: $1.pid, authorid: $1.authorid) })
    }
}

// MARK: - Helper

/// 比较两个optional是否相等
///
/// - Parameters:
///   - lhs: 左值
///   - rhs: 右值
/// - Returns: 都不为nil且相等，或者都为nil时返回true
private func ==<T: Equatable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let(l?, r?):
        return l == r
    case (nil, nil):
        return true
    default:
        return false
    }
}
