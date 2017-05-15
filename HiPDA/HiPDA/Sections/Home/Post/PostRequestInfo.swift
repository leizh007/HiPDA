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
    
    init(tid: Int, page: Int = 1, pid: Int? = nil) {
        self.tid = tid
        self.page = page
        self.pid = pid
    }
    
    init?(urlString: String) {
        guard let result = try? Regex.firstMatch(in: urlString, of: "https:\\/\\/www\\.hi-pda\\.com\\/forum\\/viewthread\\.php\\?tid=(\\d+)&extra=page%3D1&page=(\\d+)|https:\\/\\/www\\.hi-pda\\.com\\/forum\\/viewthread\\.php\\?tid=(\\d+)&rpid=41821617&ordertype=0&page=(\\d+)#pid(\\d+)|https:\\/\\/www\\.hi-pda\\.com\\/forum\\/viewthread\\.php\\?tid=(\\d+)&extra=page%3D1"),
            result.count == 7 else {
                return nil
        }
        
        switch (result[1].isEmpty, result[2].isEmpty, result[3].isEmpty, result[4].isEmpty, result[5].isEmpty, result[6].isEmpty) {
        case (false, false, true, true, true, true):
            guard let tid = Int(result[1]) else { return nil }
            self.tid = tid
            guard let page = Int(result[2]) else { return nil }
            self.page = page
            pid = nil
        case (true, true, false, false, false, true):
            guard let tid = Int(result[3]) else { return nil }
            self.tid = tid
            guard let page = Int(result[4]) else { return nil }
            self.page = page
            guard let pid = Int(result[5]) else { return nil }
            self.pid = pid
        case (true, true, true, true, true, false):
            guard let tid = Int(result[6]) else { return nil }
            self.tid = tid
            page = 1
            pid = nil
        default:
            return nil
        }
    }
}

// MARK: - Equatable

extension PostInfo: Equatable {
    static func ==(lhs: PostInfo, rhs: PostInfo) -> Bool {
        return lhs.tid == rhs.tid &&
        lhs.page == rhs.page &&
        lhs.pid == rhs.pid
    }
}

// MARK: - Lens

extension PostInfo {
    enum lens {
        static let page = Lens<PostInfo, Int>(get: { $0.page }, set: { return PostInfo(tid: $1.tid, page: $0, pid: $1.pid) })
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
