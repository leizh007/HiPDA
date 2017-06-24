//
//  ProfileActionSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

enum ProfileAction {
    case remark
    case pm
    case friend
    case search
    case block
}

extension ProfileAction: CustomStringConvertible {
    var description: String {
        switch self {
        case .remark:
            return "设置备注"
        case .pm:
            return "发短消息"
        case .friend:
            return "加为好友"
        case .search:
            return "搜索帖子"
        case .block:
            return "加入黑名单"
        }
    }
}

struct ProfileActionSection: ProfileSection {
    var header: String?
    var items: [ProfileAction]
    var isCollapsed: Bool
    
    static func createInstance(from html: String) throws -> ProfileActionSection {
        return ProfileActionSection(header: nil,
                                    items: [.remark, .pm, .friend, .search, .block],
                                    isCollapsed: false)
    }
}
