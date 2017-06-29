//
//  FriendMessageModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct FriendMessageModel: BaseMessageModel {
    let isRead: Bool
    let sender: User
    let time: String
}

// MARK: - Serializable

extension FriendMessageModel: Serializable { }

// MARK: - Decodable

extension FriendMessageModel: Decodable {
    static func decode(_ json: JSON) -> Decoded<FriendMessageModel> {
        return curry(FriendMessageModel.init(isRead:sender:time:))
            <^> json <| "isRead"
            <*> json <| "sender"
            <*> json <| "time"
    }
}

// MARK: - Equalable

extension FriendMessageModel: Equatable {
    static func ==(lhs: FriendMessageModel, rhs: FriendMessageModel) -> Bool {
        return lhs.sender == rhs.sender && lhs.time == rhs.time
    }
}
