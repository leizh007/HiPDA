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

struct ProfileActionSection: ProfileSection {
    var header: String?
    var items: [ProfileAction]
    static func createInstance(from html: String) throws -> ProfileActionSection {
        return ProfileActionSection(header: nil,
                                    items: [.remark, .pm, .friend, .search, .block])
    }
}
