//
//  ProfileBaseInfoSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct ProfileBaseInfo {
    let name: String
    let value: String
}

extension ProfileBaseInfo: Equatable {
    static func ==(lhs: ProfileBaseInfo, rhs: ProfileBaseInfo) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}

struct ProfileBaseInfoSection: ProfileSection {
    var header: String?
    var items: [ProfileBaseInfo]
    
    static func createInstance(from html: String) throws -> ProfileBaseInfoSection {
        let header = try ProfileBaseInfoSection.header(in: html) ?? "基本信息"
        let additionalItems = try ProfileBaseInfoSection.additionalItems(in: html)
        let items = try ProfileBaseInfoSection.items(in: html)
        var infos = additionalItems ?? []
        infos.append(contentsOf: items ?? [])
        
        return ProfileBaseInfoSection(header: header, items: infos)
    }
    
    private static func header(in html: String) throws -> String? {
        let result = try Regex.firstMatch(in: html, of: "<h3[^>]*>([\\s\\S]*?)<\\/h3>")
        if result.count == 2 && !result[1].isEmpty {
            return try ProfileSectionType.contentText(in: result[1])
        } else {
            return nil
        }
    }
    
    private static func items(in html: String) throws -> [ProfileBaseInfo]? {
        var infos = [ProfileBaseInfo]()
        infos.append(contentsOf: try ProfileBaseInfoSection.itemsInTbody(html))
        infos.append(contentsOf: try ProfileBaseInfoSection.itemsInUL(html))
        infos.append(contentsOf: try ProfileBaseInfoSection.onlineTimeItems(html))
        
        return infos
    }
    
    // 在线时长信息
    private static func onlineTimeItems(_ html: String) throws -> [ProfileBaseInfo] {
        return try ["总计在线", "本月在线"].flatMap { str in
            let pattern = "\(str)\\s*<em>([\\d\\.]+)<\\/em>\\s*小时"
            let result = try Regex.firstMatch(in: html, of: pattern)
            if result.count == 2 && !result[1].isEmpty, let hour = Double(result[1]) {
                return ProfileBaseInfo(name: str, value: "\(hour) 小时")
            } else {
                return nil
            }
        }
    }
    
    // 用户组的信息包含在ul里result
    private static func itemsInUL(_ html: String) throws -> [ProfileBaseInfo] {
        let pattern = "<li>([\\s\\S]*?)<\\/li>"
        let results = try Regex.matches(in: html, of: pattern)
        return try results.filter { $0.count == 2 && !$0[1].isEmpty }
                    .flatMap { result in
                        guard let colonIndex = try ProfileSectionType.contentText(in: result[1]).range(of: ":")?.upperBound,
                            colonIndex < result[1].index(before: result[1].endIndex),
                            colonIndex > result[1].startIndex else { return nil }
                        let name = try ProfileSectionType.removeTrimmingWhiteSpaces(in: ProfileSectionType.contentText(in: result[1].substring(to: result[1].index(before: colonIndex))))
                        let value = try ProfileSectionType.removeTrimmingWhiteSpaces(in: ProfileSectionType.contentText(in: result[1].substring(from: result[1].index(after: colonIndex))))
                        return ProfileBaseInfo(name: name, value: value)
                    }
    }
    
    // 基本信息包含在tbody里
    private static func itemsInTbody(_ html: String) throws -> [ProfileBaseInfo] {
        let pattern = "<tr>[^<]*<th[^>]*>([^:]+):<\\/th>[^<]+<td>([^<]*)<\\/td>"
        let results = try Regex.matches(in: html, of: pattern)
        return results.filter { $0.count == 3 && !$0[1].isEmpty }
            .map { result in
                let name = ProfileSectionType.removeTrimmingWhiteSpaces(in: result[1])
                let value = ProfileSectionType.removeTrimmingWhiteSpaces(in: result[2])
                return ProfileBaseInfo(name: name, value: value)
            }
    }
    
    // 有些信息在p里面
    private static func additionalItems(in html: String) throws -> [ProfileBaseInfo]? {
        let result = try Regex.firstMatch(in: html, of: "<\\/h3>[^<]*<p>([\\s\\S]*?)<\\/p>")
        guard result.count == 2 && !result[1].isEmpty else { return nil }
        let content = try ProfileSectionType.contentText(in: result[1])
        if content.contains("信用评价") {
            return try ProfileBaseInfoSection.creditItems(in: content)
        }
        let arr = content.components(separatedBy: ":").filter { !$0.isEmpty }
        if arr.count == 2 {
            return [ProfileBaseInfo(name: ProfileSectionType.removeTrimmingWhiteSpaces(in: arr[0]),
                                    value: ProfileSectionType.removeTrimmingWhiteSpaces(in: arr[1]))]
        } else if arr.count > 2 {
            return ProfileBaseInfoSection.scoreItems(arr)
        }
        
        return nil
    }
    
    // 积分信息
    private static func scoreItems(_ arr: [String]) -> [ProfileBaseInfo]? {
        var nameValueArr = [String]()
        for str in arr {
            nameValueArr.append(contentsOf: str.components(separatedBy: ",").filter { !$0.isEmpty })
        }
        if nameValueArr.count % 2 == 0 {
            return zip(stride(from: 0, to: nameValueArr.count, by: 2),
                       stride(from: 1, to: nameValueArr.count, by: 2))
                .map {
                    return ProfileBaseInfo(name: ProfileSectionType.removeTrimmingWhiteSpaces(in :nameValueArr[$0.0]),
                                           value: ProfileSectionType.removeTrimmingWhiteSpaces(in :nameValueArr[$0.1]))
            }
        }
        
        return nil
    }
    
    // 信用信息
    private static func creditItems(in html: String) throws -> [ProfileBaseInfo] {
        var infos = [ProfileBaseInfo]()
        infos.reserveCapacity(2)
        for str in ["买家信用评价", "卖家信用评价"] {
            let credit = try Regex.firstMatch(in: html, of: "\(str):\\s*(\\d+)")
            if credit.count == 2 && !credit.isEmpty {
                infos.append(ProfileBaseInfo(name: str, value: credit[1]))
            }
        }
        return infos
    }
}
