//
//  YYCache+FriendMessage.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache
import Argo
import HandyJSON

extension YYCache {
    func friendMessages() -> [FriendMessageModel]? {
        guard let uid = Settings.shared.activeAccount?.uid else { return nil }
        let key = "FrienMessages-\(uid)"
        guard let messagesString = object(forKey: key) as? String,
            let messagesData = messagesString.data(using: .utf8),
            let data = try? JSONSerialization.jsonObject(with: messagesData, options: []),
            let arr = data as? NSArray else {
                return nil
        }
        
        return arr.flatMap {
            return try? FriendMessageModel.decode(JSON($0)).dematerialize()
        }
    }
    
    func setFriendMessages(_ friendMessages: [FriendMessageModel]) {
        guard let uid = Settings.shared.activeAccount?.uid else { return }
        let key = "FrienMessages-\(uid)"
        let messagesString = JSONSerializer.serializeToJSON(object: friendMessages) ?? ""
        setObject(messagesString as NSString, forKey: key)
    }
}
