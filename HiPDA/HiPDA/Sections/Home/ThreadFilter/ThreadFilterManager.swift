//
//  ThreadFilterManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache
import Argo
import HandyJSON

class ThreadFilterManager {
    static let shared = ThreadFilterManager()
    fileprivate let cache = CacheManager.threadFilter.shared!
    
    func filter(for forumName: String) -> ThreadFilter {
        guard let filterString = cache.object(forKey: forumName) as? String,
            let filterData = filterString.data(using: .utf8),
            let data = try? JSONSerialization.jsonObject(with: filterData, options: []),
            let dic = data as? NSDictionary else {
                return ThreadFilter(typeName: "全部", order: .lastpost)
        }
        
        return (try? ThreadFilter.decode(JSON(dic)).dematerialize()) ?? ThreadFilter(typeName: "全部", order: .lastpost)
    }
    
    func save(filter: ThreadFilter, for forumName: String) {
        let filterString = JSONSerializer.serializeToJSON(object: filter) ?? ""
        cache.setObject(filterString as NSString, forKey: forumName)
    }
}
