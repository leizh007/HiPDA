//
//  PrivateMessageViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class PrivateMessageViewModel: MessageTableViewModel {
    var privateMessageModels = [PrivateMessageModel]()
    override var models: [BaseMessageModel] {
        get {
            return privateMessageModels
        }
        set {
            privateMessageModels = newValue as? [PrivateMessageModel] ?? []
        }
    }
    
    override func modelTransform(_ html: String) throws -> [BaseMessageModel] {
        return try HtmlParser.privateMessages(from: html)
    }
    
    override func api(at page: Int) -> HiPDA.API {
        return .privateMessage(page: page)
    }
    
    override func getDataFromCache(for account: Account) {
        privateMessageModels = CacheManager.privateMessage.shared?.messages(for: account) ?? []
        page = 1
        totalPage = (CacheManager.privateMessage.shared?.object(forKey: totalPageKey(for: account)) as? NSNumber)?.intValue ?? 1
        lastUpdateTime = (CacheManager.privateMessage.shared?.object(forKey: lastUpdateTimeKey(for: account)) as? NSNumber)?.doubleValue ?? 0.0
    }
    
    override func saveModelsToCache(for account: Account) {
        guard let cache = CacheManager.privateMessage.shared else { return }
        cache.setMessages(privateMessageModels, for: account)
        cache.setObject(totalPage as NSNumber, forKey: totalPageKey(for: account))
        cache.setObject(lastUpdateTime as NSNumber, forKey: lastUpdateTimeKey(for: account))
    }
}

// MARK: - DataSource

extension PrivateMessageViewModel {
    func user(at index: Int) -> User {
        return privateMessageModels[index].sender
    }
    
    func content(at index: Int) -> String {
        return privateMessageModels[index].content
    }
    
    func time(at index: Int) -> String {
        return privateMessageModels[index].time
    }
    
    func isRead(at index: Int) -> Bool {
        return privateMessageModels[index].isRead
    }
}
