//
//  Account.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import SAMKeychain

/// 用于从Keychain中获取密码的服务名
private let passwordService = "HiPDA-password"

/// 用于从Keychain中获取问题id的服务名
private let questionidService = "HiPDA-questionid"

/// 用于从Keychain中获取答案的服务名
private let answerService = "HiPDA-answer"

/// 存取键
private struct AccountKeys {
    static let serviceName = "HiPDA"
    static let name = "name"
    static let uid = "uid"
}

/// APP登录账户
struct Account {
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
        
        questionid = Int(SAMKeychain.password(forService: questionidService, account: name)) ?? 0
        answer = SAMKeychain.password(forService: answerService, account: name) ?? ""
        password = SAMKeychain.password(forService: passwordService, account: name)
        
        avatarImageURL = URL(string: String(format: "http://img.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg", uid/1000000, (uid%1000000)/10000, (uid%10000)/100, uid%100))!
    }
    
    func encode() -> Data {
        let dictionary: [String : Any] = [
            AccountKeys.name: name,
            AccountKeys.uid: uid,
            ]
        
        SAMKeychain.setPassword(password, forService: passwordService, account: name)
        SAMKeychain.setPassword(String(questionid), forService: questionidService, account: name)
        SAMKeychain.setPassword(answer, forService: answerService, account: name)
        
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)
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
