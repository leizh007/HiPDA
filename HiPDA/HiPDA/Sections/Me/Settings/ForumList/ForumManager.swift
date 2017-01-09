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
}
