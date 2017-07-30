//
//  CacheManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache

private let kTidsKey = "kTidsKey"

/// 缓存管理
enum CacheManager: String {
    /// 帖子浏览历史
    case threadsReadHistory
    
    /// 帖子列表
    case threads
    
    /// 草稿
    case draft
    
    case threadMessage
    
    case privateMessage
    
    case friendMessage
    
    case threadFilter
    
    case settings
    
    private static var dic = [String: YYCache]()
    
    // FIXME: -  待优化
    private static let cacheCountLimit = UInt(200)
    
    private static let lock = NSRecursiveLock()
    
    /// 缓存实例
    var shared: YYCache? {
        CacheManager.lock.lock()
        defer {
            CacheManager.lock.unlock()
        }
        guard CacheManager.dic[self.rawValue] == nil else {
            return CacheManager.dic[self.rawValue]
        }
        guard let cache = YYCache(name: self.rawValue) else {
            return nil
        }
        skinCache(cache)
        CacheManager.dic[self.rawValue] = cache
        
        return cache
    }
    
    /// 配置cache属性
    ///
    /// - Parameter cache: YYCache
    private func skinCache(_ cache: YYCache) {
        cache.lock = NSRecursiveLock()
        var countLimit = CacheManager.cacheCountLimit
        
        /// 目前只有浏览历史的条数可以用户自己设定
        if self == .threadsReadHistory && Settings.shared.threadHistoryCountLimit > 0 {
            countLimit = UInt(Settings.shared.threadHistoryCountLimit)
        }
        cache.memoryCache.countLimit = countLimit
        cache.diskCache.countLimit = countLimit
        cache.tids = cache.object(forKey: kTidsKey) as? [Int] ?? []
        /// 只有浏览历史使用LRU策略，其他的就按添加时间进行排列
        cache.useLRUStrategy = self == .threadsReadHistory
    }
    
    static func save() {
        guard let cache = CacheManager.threadsReadHistory.shared else { return }
        cache.setObject(cache.tids as NSCoding, forKey: kTidsKey)
    }
}
