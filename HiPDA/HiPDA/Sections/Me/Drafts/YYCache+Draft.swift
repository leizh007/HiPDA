//
//  YYCache+Draft.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/7.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache
import Argo
import HandyJSON

extension YYCache {
    enum Constants {
        static let draftKey = "draft"
    }
    
    func drafts() -> [Draft] {
        guard let draftsString = object(forKey: Constants.draftKey) as? String,
            let draftsData = draftsString.data(using: .utf8),
            let data = try? JSONSerialization.jsonObject(with: draftsData, options: []),
            let arr = data as? NSArray else {
                return []
        }
        
        return arr.flatMap {
            return try? Draft.decode(JSON($0)).dematerialize()
        }
    }
    
    func setDrafts(_ drafts: [Draft]) {
        let draftsString = JSONSerializer.serializeToJSON(object: drafts) ?? ""
        setObject(draftsString as NSString, forKey: Constants.draftKey)
    }
}
