//
//  Account.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// APP登录账户
struct Account {
    private struct AccountKeys {
        static let serviceName = "HiPDA"
        static let name = "name"
        static let uid = "uid"
        static let password = "password"
        static let questionid = "questionid"
        static let answer = "answer"
    }
    
    let name: String
    let uid: Int
    let questionid: Int
    let answer: String
    let password: String
    
    /// 默认中分辨率的头像链接
    let avatarImageURL: URL
    
    init(name: String, uid: Int, questionid: Int, answer: String, password: String) {
        self.name = name
        self.uid = uid
        self.questionid = questionid
        self.answer = answer
        self.password = password
        avatarImageURL = URL(string: String(format: "http://img.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg", uid/1000000, (uid%1000000)/10000, (uid%10000)/100, uid%100))!
    }
}

// MARK: - Serializable Protocol

extension Account: Serializable {
    init(_ data: Data) {
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
        name = dictionary[AccountKeys.name] as! String
        uid = dictionary[AccountKeys.uid] as! Int
        questionid = dictionary[AccountKeys.questionid] as! Int
        answer = dictionary[AccountKeys.answer] as! String
        password = dictionary[AccountKeys.password] as! String
        avatarImageURL = URL(string: String(format: "http://img.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg", uid/1000000, (uid%1000000)/10000, (uid%10000)/100, uid%100))!
    }
    
    func encode() -> Data {
        let dictionary = [
            AccountKeys.name: name,
            AccountKeys.uid: uid,
            AccountKeys.questionid: questionid,
            AccountKeys.answer: answer,
            AccountKeys.password: password
        ]
        
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)
    }
}

// MARK: - Equalable

func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.name == rhs.name &&
    lhs.uid == rhs.uid &&
    lhs.questionid == rhs.questionid &&
    lhs.answer == rhs.answer &&
    lhs.password == rhs.password
}

func !=(lhs: Account, rhs: Account) -> Bool {
    return !(lhs == rhs)
}
