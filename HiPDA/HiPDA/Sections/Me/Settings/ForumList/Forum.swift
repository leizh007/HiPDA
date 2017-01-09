//
//  Thread.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

private let kForumNameKey = "forumName"
private let kForumIdKey = "forumId"
private let kForumDescriptionKey = "description"
private let kForumTypenamesKey = "typeidList"
private let kSubForumsKey = "subForumList"

struct Forum {
    let name: String
    let id: Int
    let description: String?
    let typeNames: [String]?
    let subForums: [Forum]?
}

// MARK: - Serializable

extension Forum: Serializable { }

// MARK: - Decodable

extension Forum: Decodable {
    static func decode(_ json: JSON) -> Decoded<Forum> {
        return curry(Forum.init)
        <^> json <| kForumNameKey
        <*> json <| kForumIdKey
        <*> json <|? kForumDescriptionKey
        <*> json <||? kForumTypenamesKey
        <*> json <||? kSubForumsKey
    }
}

// MARK: - Equable

extension Forum: Equatable {
    static func ==(lhs: Forum, rhs: Forum) -> Bool {
        return lhs.id == rhs.id
    }
}
