//
//  Account.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

/// 存取键
private struct AccountKeys {
    static let name = "name"
    static let uid = "uid"
    static let questionid = "questionid"
    static let answer = "answer"
    static let password = "password"
}

/// APP登录账户
struct Account {
    let name: String
    let uid: Int
    let questionid: Int
    let answer: String
    let password: String
    
    /// 默认高辨率的头像链接
    let avatarImageURL: URL
    
    init(name: String, uid: Int, questionid: Int, answer: String, password: String) {
        self.name = name
        self.uid = uid
        self.questionid = questionid
        self.answer = answer
        self.password = password
        avatarImageURL = URL(string: String(format: "http://img.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_big.jpg", uid/1000000, (uid%1000000)/10000, (uid%10000)/100, uid%100))!
    }
}

// MARK: - Serializable

extension Account: Serializable { }

// MARK: - Decodable

extension Account: Decodable {
    static func decode(_ json: JSON) -> Decoded<Account> {
        return curry(Account.init(name:uid:questionid:answer:password:))
            <^> json <| AccountKeys.name
            <*> json <| AccountKeys.uid
            <*> json <| AccountKeys.questionid
            <*> json <| AccountKeys.answer
            <*> json <| AccountKeys.password
    }
}

// MARK: - Equalable

extension Account: Equatable {
    
}

func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.name == rhs.name &&
    lhs.uid == rhs.uid &&
    lhs.questionid == rhs.questionid &&
    lhs.answer == rhs.answer &&
    lhs.password == rhs.password
}
