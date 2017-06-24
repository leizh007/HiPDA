//
//  ProfileAccountSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct ProfileAccountSection: ProfileSection {
    var header: String?
    var items: [User]
    var isCollapsed: Bool
    
    static func createInstance(from html: String) throws -> ProfileAccountSection {
        let pattern = "<h1>([\\s\\S]*?)<\\/h1>[^<]*<ul>[^<]*<li>\\(UID:\\s*(\\d+)\\)<\\/li>"
        let result = try Regex.firstMatch(in: html, of: pattern)
        guard result.count == 3 && !result[1].isEmpty && !result[2].isEmpty,
            let uid = Int(result[2]) else {
                throw HtmlParserError.unKnown("获取用户信息出错")
        }
        let content = try ProfileSectionType.contentText(in: result[1])
        let name = ProfileSectionType.removeTrimmingWhiteSpaces(in: content)
        return ProfileAccountSection(header: nil, items: [User(name: name, uid: uid)], isCollapsed: false)
    }
}
