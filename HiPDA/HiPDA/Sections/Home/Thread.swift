//
//  Thread.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

extension HiPDA {
    /// 帖子
    struct Thread {
        let id: Int
        let title: String
        let attachment: HiPDA.ThreadAttachment
        let user: User
        let postTime: String
        let replyCount: Int
        let readCount: Int
    }
}

// MARK: - Serializable

extension HiPDA.Thread: Serializable { }

// MARK: - Decodable

extension HiPDA.Thread: Decodable {
    static func decode(_ json: JSON) -> Decoded<HiPDA.Thread> {
        return curry(HiPDA.Thread.init(id:title:attachment:user:postTime:replyCount:readCount:))
        <^> json <| "id"
        <*> json <| "title"
        <*> json <| "attachment"
        <*> json <| "user"
        <*> json <| "postTime"
        <*> json <| "replyCount"
        <*> json <| "readCount"
    }
}

// MARK: - Equalable

extension HiPDA.Thread: Equatable {
    static func ==(lhs: HiPDA.Thread, rhs: HiPDA.Thread) -> Bool {
        return lhs.id == rhs.id
    }
}
