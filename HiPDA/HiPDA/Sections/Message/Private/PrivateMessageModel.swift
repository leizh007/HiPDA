//
//  PrivateMessageModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct PrivateMessageModel: BaseMessageModel {
    let sender: User
    let time: String
    let content: String
    let isRead: Bool
    let url: String
}

// MARK: - Serializable

extension PrivateMessageModel: Serializable { }

// MARK: - Decodable

extension PrivateMessageModel: Decodable {
    static func decode(_ json: JSON) -> Decoded<PrivateMessageModel> {
        return curry(PrivateMessageModel.init(sender:time:content:isRead:url:))
            <^> json <| "sender"
            <*> json <| "time"
            <*> json <| "content"
            <*> json <| "isRead"
            <*> json <| "url"
    }
}

// MARK: - Equalable

extension PrivateMessageModel: Equatable {
    static func ==(lhs: PrivateMessageModel, rhs: PrivateMessageModel) -> Bool {
        return lhs.sender == rhs.sender &&
            lhs.time == rhs.time &&
            lhs.content == rhs.content &&
            lhs.url == rhs.url
    }
}
