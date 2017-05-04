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

/// 帖子
struct HiPDAThread {
    let id: Int
    let title: String
    let attachment: HiPDAThreadAttachment
    let user: User
    let postTime: String
    let replyCount: Int
    let readCount: Int
}

// MARK: - Serializable

extension HiPDAThread: Serializable { }

// MARK: - Decodable

extension HiPDAThread: Decodable {
    static func decode(_ json: JSON) -> Decoded<HiPDAThread> {
        return curry(HiPDAThread.init(id:title:attachment:user:postTime:replyCount:readCount:))
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

extension HiPDAThread: Equatable {
    static func ==(lhs: HiPDAThread, rhs: HiPDAThread) -> Bool {
        return lhs.id == rhs.id
    }
}
