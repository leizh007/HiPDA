//
//  YYCache+Message.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache
import Argo
import HandyJSON

extension YYCache {
    func messages<T: Decodable>(for account: Account) -> [T]? {
        let uid = account.uid
        let key = "\(String(describing: T.self))-\(uid)"
        guard let messagesString = object(forKey: key) as? String,
            let messagesData = messagesString.data(using: .utf8),
            let data = try? JSONSerialization.jsonObject(with: messagesData, options: []),
            let arr = data as? NSArray else {
                return nil
        }
        
        return arr.flatMap {
            return ((try? T.decode(JSON($0)).dematerialize()) as? T) ?? nil
        }
    }
    
    func setMessages<T>(_ messages: [T], for account: Account) {
        let uid = account.uid
        let key = "\(String(describing: T.self))-\(uid)"
        var messagesString = JSONSerializer.serializeToJSON(object: messages) ?? ""
        messagesString = messagesString.replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\t", with: "\\t")
        setObject(messagesString as NSString, forKey: key)
    }
}
