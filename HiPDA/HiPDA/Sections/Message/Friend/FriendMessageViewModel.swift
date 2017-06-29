//
//  FriendMessageTableViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class FriendMessageViewModel: MessageTableViewModel {
    var friendMessageModels = [FriendMessageModel]()
    override var models: [BaseMessageModel] {
        get {
            return friendMessageModels
        }
        set {
            friendMessageModels = newValue as? [FriendMessageModel] ?? []
        }
    }
    
    override func getDataFromCache(for account: Account) {
        friendMessageModels = CacheManager.friendMessage.shared?.messages(for: account) ?? []
        page = 1
        totalPage = (CacheManager.friendMessage.shared?.object(forKey: totalPageKey) as? NSNumber)?.intValue ?? 1
        lastUpdateTime = (CacheManager.friendMessage.shared?.object(forKey: lastUpdateTimeKey) as? NSNumber)?.doubleValue ?? 0.0
    }
    
    override func saveModelsToCache(for account: Account) {
        guard let cache = CacheManager.friendMessage.shared else { return }
        cache.setMessages(friendMessageModels, for: account)
        cache.setObject(totalPage as NSNumber, forKey: totalPageKey)
        cache.setObject(lastUpdateTime as NSNumber, forKey: lastUpdateTimeKey)
    }
    
    override func loadData(at page: Int, completion: @escaping (HiPDA.Result<[BaseMessageModel], NSError>) -> Void) {
        disposeBag = DisposeBag()
        var totalPage = self.totalPage
        HiPDAProvider.request(.friendMessage(page: page))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .do(onNext: { html in
                totalPage = try HtmlParser.totalPage(from: html)
            })
            .map { try HtmlParser.friendMessages(from: $0) }
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
    
    func addFriend(at index: Int, completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        let uid = friendMessageModels[index].sender.uid
        NetworkUtilities.addFriend(uid: uid, completion: completion)
    }

}

// MARK: - DataSource

extension FriendMessageViewModel {
    func title(at index: Int) -> String {
        return "\(friendMessageModels[index].sender.name) 添加您为好友"
    }
    
    func time(at index: Int) -> String {
        return friendMessageModels[index].time
    }
    
    func isRead(at index: Int) -> Bool {
        return friendMessageModels[index].isRead
    }
    
    func model(at index: Int) -> FriendMessageModel {
        return friendMessageModels[index]
    }
}
