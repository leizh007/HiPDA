//
//  ForumManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

private let kForumTypeIdDictionaryKey = "typeIdDictionary"
private let kForumListKey = "forumList"

struct ForumManager {
    fileprivate static let attributes: [String: Any] = {
        guard let attributesPath = Bundle.main.path(forResource: "ForumList", ofType: "plist") else {
            return [:]
        }
        return NSDictionary(contentsOfFile: attributesPath) as? [String: Any] ?? [:]
    }()
    
    fileprivate static let typeidDictionary: [String: Int] = {
        ForumManager.attributes[kForumTypeIdDictionaryKey] as? [String: Int] ?? [:]
    }()
    
    static let forums: [Forum] = {
        let forumList = ForumManager.attributes[kForumListKey] as? [[String: Any]] ?? []
        return forumList.lazy
            .map {
                try? Forum.decode(JSON($0)).dematerialize()
            }
            .flatMap { $0 }
    }()
    
    fileprivate static let flattenedForums: [Forum] = {
        return ForumManager.forums.reduce([]) { (result, forum) -> [Forum] in
            var result = result
            result.append(forum)
            result.append(contentsOf: forum.subForums ?? [])
            return result
        }
    }()
    
    static fileprivate let fidDictionary: [String: Int] = {
        var dictionary = [String: Int]()
        for forum in ForumManager.forums {
            dictionary[forum.name] = forum.id
            for subForum in forum.subForums ?? [] {
                dictionary[subForum.name] = subForum.id
            }
        }
        return dictionary
    }()
    
    static fileprivate let forumNameDictionary: [Int: String] = {
        var dictionary = [Int: String]()
        for forum in ForumManager.forums {
            dictionary[forum.id] = forum.name
            for subForum in forum.subForums ?? [] {
                dictionary[subForum.id] = subForum.name
            }
        }
        return dictionary
    }()
    
    static func typeNames(of fid: Int) -> [String] {
        return ForumManager.flattenedForums.filter { $0.id == fid }.first?.typeNames ?? []
    }
    
    static func typeid(of name: String) -> Int {
        return typeidDictionary[name] ?? 0
    }
    
    /// 根据版块名称获取版块id
    ///
    /// - Parameter name: 版块名称
    /// - Returns: 版块id
    static func fid(ofForumName name: String) -> Int {
        return ForumManager.fidDictionary[name] ?? 0
    }
    
    static func forumName(ofFid fid: Int) -> String {
        return ForumManager.forumNameDictionary[fid] ?? ""
    }
    
    static let defalutForumNameList = ["Discovery", "Buy & Sell 交易服务区", "E-INK", "Geek Talks · 奇客怪谈", "疑似机器人"]
}
