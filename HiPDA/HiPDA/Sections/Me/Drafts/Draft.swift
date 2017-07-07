//
//  Draft.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct Draft {
    let fid: Int
    let forumName: String
    let typeName: String
    let time: String
    let title: String
    let content: String
    let imageNumbers: [Int]
}

// MARK: - Serializable

extension Draft: Serializable { }

// MARK: - Decodable

extension Draft: Decodable {
    static func decode(_ json: JSON) -> Decoded<Draft> {
        return curry(Draft.init(fid:forumName:typeName:time:title:content:imageNumbers:))
            <^> json <| "fid"
            <*> json <| "forumName"
            <*> json <| "typeName"
            <*> json <| "time"
            <*> json <| "title"
            <*> json <| "content"
            <*> json <|| "imageNumbers"
    }
}

// MARK: - Equalable

extension Draft: Equatable {
    static func ==(lhs: Draft, rhs: Draft) -> Bool {
        return lhs.fid == rhs.fid &&
            lhs.forumName == rhs.forumName &&
            lhs.typeName == rhs.typeName &&
            lhs.time == rhs.time &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content &&
            lhs.imageNumbers == rhs.imageNumbers
    }
}

