//
//  ThreadMessageViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class ThreadMessageViewModel: MessageTableViewModel {
    var threadMessageModels = [ThreadMessageModel]()
    override var models: [BaseMessageModel] {
        get {
            return threadMessageModels
        }
        set {
            threadMessageModels = newValue as? [ThreadMessageModel] ?? []
        }
    }
    
    override func getDataFromCache(for account: Account) {
        threadMessageModels = CacheManager.threadMessage.shared?.messages(for: account) ?? []
        page = 1
        totalPage = (CacheManager.threadMessage.shared?.object(forKey: totalPageKey) as? NSNumber)?.intValue ?? 1
        lastUpdateTime = (CacheManager.friendMessage.shared?.object(forKey: lastUpdateTimeKey) as? NSNumber)?.doubleValue ?? 0.0
    }
    
    override func saveModelsToCache(for account: Account) {
        guard let cache = CacheManager.threadMessage.shared else { return }
        cache.setMessages(threadMessageModels, for: account)
        cache.setObject(totalPage as NSNumber, forKey: totalPageKey)
        cache.setObject(lastUpdateTime as NSNumber, forKey: lastUpdateTimeKey)
    }
    
    override func loadData(at page: Int, completion: @escaping (HiPDA.Result<[BaseMessageModel], NSError>) -> Void) {
        disposeBag = DisposeBag()
        var totalPage = self.totalPage
        HiPDAProvider.request(.threadMessage(page: page))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .do(onNext: { html in
                totalPage = try HtmlParser.totalPage(from: html)
            })
            .map { try HtmlParser.threadMessages(from: $0) }
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .next(let models):
                    self?.totalPage = totalPage
                    completion(.success(models))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
}

extension ThreadMessageViewModel {
    func title(at index: Int) -> String {
        let model = threadMessageModels[index]
        return "\(model.senderName) 在\(model.time)\(model.action)\"\(model.postTitle)\"\(model.postAction)"
    }
    
    func yourPost(at index: Int) -> String? {
        if let post = threadMessageModels[index].yourPost {
            return "您的帖子: \(post)"
        }
        return nil
    }
    
    func senderPost(at index: Int) -> String? {
        if let post = threadMessageModels[index].senderPost {
            return "\(threadMessageModels[index].senderName) 说: \(post)"
        }
        return nil
    }
    
    func isRead(at index: Int) -> Bool {
        return threadMessageModels[index].isRead
    }
    
    func postURL(at index: Int) -> String {
        return threadMessageModels[index].postURL
    }
}
