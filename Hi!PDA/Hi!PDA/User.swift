//
//  File.swift
//  Hi!PDA
//
//  Created by leizh007 on 16/6/13.
//  Copyright © 2016年 Hi!PDA. All rights reserved.
//

import Foundation

/**
 序列化
 */
protocol Serializable {
    init(data: NSData)
    func encode() -> NSData
}

/**
 帖子用户
 */
struct User {
    let name: String
    let uid: Int
    var avatarImageURL: NSURL {
        return NSURL(string: String(format: "http://img.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg", uid/1000000,(uid%1000000)/10000,(uid%10000)/100,uid%100))!
    }
}

//MARK: - Serializable protocol
extension User: Serializable {
    init(data: NSData) {
        let dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
        name = dictionary["name"] as! String
        uid = (dictionary["uid"] as! NSNumber).integerValue
    }
    
    func encode() -> NSData {
        let dictionary = NSMutableDictionary()
        dictionary["name"] = name
        dictionary["uid"] = NSNumber(integer: uid)
        return NSKeyedArchiver.archivedDataWithRootObject(dictionary)
    }
}

//MARK: - Equal Operator
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.uid == rhs.uid
}

func !=(lhs: User, rhs: User) -> Bool {
    return !(lhs == rhs)
}