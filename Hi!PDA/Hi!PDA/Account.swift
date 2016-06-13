//
//  Account.swift
//  Hi!PDA
//
//  Created by leizh007 on 16/6/13.
//  Copyright © 2016年 Hi!PDA. All rights reserved.
//

import Foundation
import SSKeychain

/**
 APP已登陆账户
 */
struct Account {
    // MARK: - keys
    private struct AccountKeys {
        static let ServiceName = "Hi!PDA"
        static let Name = "name"
        static let Uid = "uid"
        static let Password = "password"
        static let Questionid = "questionid"
        static let Answer = "answer"
    }
    
    // MARK: - properties
    let name: String
    let uid: Int
    let questionid: Int
    let answer: String
    let password: String
    var avatarImageURL: NSURL {
        return NSURL(string: String(format: "http://img.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg", uid/1000000,(uid%1000000)/10000,(uid%10000)/100,uid%100))!
    }
}

//MARK: - Serializable protocol
extension Account: Serializable {
    init(data: NSData) {
        let dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
        name = dictionary[AccountKeys.Name] as! String
        uid = (dictionary[AccountKeys.Uid] as! NSNumber).integerValue
        questionid = (dictionary[AccountKeys.Questionid] as! NSNumber).integerValue
        answer = dictionary[AccountKeys.Answer] as! String
        if let password = SSKeychain.passwordForService(AccountKeys.ServiceName, account: name) {
            self.password = password
        } else {
            self.password = ""
        }
    }
    
    func encode() -> NSData {
        let dictionary = NSMutableDictionary()
        dictionary[AccountKeys.Name] = name
        dictionary[AccountKeys.Uid] = NSNumber(integer: uid)
        dictionary[AccountKeys.Questionid] = NSNumber(integer: questionid)
        dictionary[AccountKeys.Answer] = answer
        SSKeychain.setPassword(password, forService: AccountKeys.ServiceName, account: name)
        return NSKeyedArchiver.archivedDataWithRootObject(dictionary)
    }
}

//MARK: - Equal Operator
func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.uid == rhs.uid
}

func !=(lhs: Account, rhs: Account) -> Bool {
    return !(lhs == rhs)
}