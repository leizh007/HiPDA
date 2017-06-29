//
//  ThreadMessageModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct ThreadMessageModel: BaseMessageModel {
    let isRead: Bool
    let senderName: String
    let action: String
    let postTitle: String
    let postAction: String
    let postURL: String
    let time: String
    let yourPost: String?
    let senderPost: String?
}

// MARK: - Serializable

extension ThreadMessageModel: Serializable { }

// MARK: - Decodable

extension ThreadMessageModel: Decodable {
    static func decode(_ json: JSON) -> Decoded<ThreadMessageModel> {
        return curry(ThreadMessageModel.init(isRead:senderName:action:postTitle:postAction:postURL:time:yourPost:senderPost:))
            <^> json <| "isRead"
            <*> json <| "senderName"
            <*> json <| "action"
            <*> json <| "postTitle"
            <*> json <| "postAction"
            <*> json <| "postURL"
            <*> json <| "time"
            <*> json <|? "yourPost"
            <*> json <|? "senderPost"
    }
}

// MARK: - Equalable

extension ThreadMessageModel: Equatable {
    static func ==(lhs: ThreadMessageModel, rhs: ThreadMessageModel) -> Bool {
        return lhs.senderName == rhs.senderName &&
            lhs.action == rhs.action &&
            lhs.postTitle == rhs.postTitle &&
            lhs.postAction == rhs.postAction &&
            lhs.postURL == rhs.postURL &&
            lhs.time == rhs.time &&
            optionalEqual(lhs.yourPost, rhs.yourPost) &&
            optionalEqual(lhs.senderPost, rhs.senderPost)
    }
}
