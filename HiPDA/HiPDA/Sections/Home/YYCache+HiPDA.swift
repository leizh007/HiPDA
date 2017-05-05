//
//  YYCache+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache
import Argo

// MARK: - Associated Object
private var kTidsKey: Void?
private var kLRUKey: Void?

extension YYCache {
    /// 帖子id的数组，0到N-1按时间从近到远
    var tids: [Int] {
        get {
            return objc_getAssociatedObject(self, &kTidsKey) as? [Int] ?? []
        }
        
        set {
            objc_setAssociatedObject(self, &kTidsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// tids是否使用LRU策略
    var useLRUStrategy: Bool {
        get {
            return objc_getAssociatedObject(self, &kLRUKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &kLRUKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否包含帖子
    ///
    /// - Parameter thread: 帖子
    /// - Returns: 包含返回true，否则返回false
    func containsThread(_ thread: HiPDAThread) -> Bool {
        return containsObject(forKey: "\(thread.id)")
    }
    
    /// 根据id查找帖子
    ///
    /// - Parameter id: 帖子id
    /// - Returns: 找到帖子返回，否则返回nil
    func thread(for id: Int) -> HiPDAThread? {
        if useLRUStrategy, let index = tids.index(of: id) {
            tids.insert(tids.remove(at: index), at: 0)
        }
        guard let threadString = object(forKey: "\(id)") as? String else { return nil }
        let threadData = threadString.data(using: .utf8) ?? Data()
        guard let attributes = try? JSONSerialization.jsonObject(with: threadData, options: []) else { return nil }
        return try? HiPDAThread.decode(JSON(attributes)).dematerialize()
    }
    
    /// 添加帖子
    ///
    /// - Parameter thread: 帖子
    func setThread(_ thread: HiPDAThread) {
        if let index = tids.index(of: thread.id) {
            tids.remove(at: index)
        }
        tids.insert(thread.id, at: 0)
        let threadString = thread.encode()
        setObject(threadString as NSString, forKey: "\(thread.id)")
    }
    
    /// 移除帖子
    ///
    /// - Parameter thread: 帖子
    func removeThread(_ thread: HiPDAThread) {
        tids = tids.filter { $0 != thread.id }
        removeObject(forKey: "\(thread.id)")
    }
    
    /// 清空缓存
    func clear() {
        removeAllObjects()
    }
}
