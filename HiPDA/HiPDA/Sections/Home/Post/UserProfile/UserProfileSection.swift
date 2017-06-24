//
//  UserProfileSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

protocol ProfileSection {
    associatedtype Item
    var header: String? { get }
    var items: [Item] { get }
    var isCollapsed: Bool { get }
    static func createInstance(from html: String) throws -> Self
}

enum ProfileSectionType {
    case account(ProfileAccountSection)
    case action(ProfileActionSection)
    case baseInfo(ProfileBaseInfoSection)
    var isCollapsed: Bool {
        switch self {
        case .account(let account):
            return account.isCollapsed
        case .action(let action):
            return action.isCollapsed
        case .baseInfo(let baseInfo):
            return baseInfo.isCollapsed
        }
    }
    
    var items: [Any] {
        switch self {
        case .account(let account):
            return account.items
        case .action(let action):
            return action.items
        case .baseInfo(let baseInfo):
            return baseInfo.items
        }
    }
    
    var header: String? {
        switch self {
        case .account(let account):
            return account.header
        case .action(let action):
            return action.header
        case .baseInfo(let baseInfo):
            return baseInfo.header
        }
    }
}

extension ProfileSectionType {
    static func contentText(in html: String) throws -> String {
        var html = html as NSString
        for str in ["<[^>]*>", "\\([^\\)]+\\)"] {
            let regex = try Regex.regularExpression(of: str)
            let results = regex.matches(in: html as String, range: NSRange(location: 0, length: html.length))
            for result in results.reversed() {
                let range = result.range
                html = html.replacingCharacters(in: range, with: "") as NSString
            }
        }
        
        return ProfileSectionType.removeTrimmingWhiteSpaces(in: (html as String))
    }
    
    static func removeTrimmingWhiteSpaces(in string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
