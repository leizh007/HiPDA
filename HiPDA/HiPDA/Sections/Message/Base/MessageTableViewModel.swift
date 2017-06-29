//
//  MessageTableViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

typealias MessageListResult = HiPDA.Result<Void, NSError>

class MessageTableViewModel {
    var disposeBag = DisposeBag()
    var models = [BaseMessageModel]()
    var totalPageKey: String {
        return "totalPage-\(Settings.shared.activeAccount?.uid ?? 0)"
    }
    var totalPage = 1
    var page = 1
    var unReadMessagesCount = 0
    var lastUpdateTimeKey: String {
        return "lastUpdateTime-\(Settings.shared.activeAccount?.uid ?? 0)"
    }
    var lastUpdateTime = Date().timeIntervalSince1970
    var isThreadsOutOfDate: Bool {
        return Date().timeIntervalSince1970 - lastUpdateTime > 60 * 60
    }
    var shouldRefresh: Bool {
        let count = models.filter { !$0.isRead }.count
        return count != unReadMessagesCount || isThreadsOutOfDate
    }
    var hasData: Bool {
        return models.count > 0
    }
    var hasMoreData: Bool {
        return totalPage > page
    }
    
    func loadData(at page: Int, completion: @escaping (HiPDA.Result<[BaseMessageModel], NSError>) -> Void) {
        disposeBag = DisposeBag()
    }
    
    init() {
    }
    
    func accountChanged(_ account: Account) {
        getDataFromCache(for: account)
    }
    
    func getDataFromCache(for account: Account) {
        
    }
    
    func saveModelsToCache(for account: Account) {
        
    }
    
    func cancelDataFetching() {
        disposeBag = DisposeBag()
    }
}

// MARK: - Data Load

extension MessageTableViewModel {
    func loadNewData(completion: @escaping (MessageListResult) -> Void) {
        let page = 1
        loadData(at: page) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let models):
                self.models = models
                self.page = page
                self.lastUpdateTime = Date().timeIntervalSince1970
                if let account = Settings.shared.activeAccount {
                    self.saveModelsToCache(for: account)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadMoreData(completion: @escaping (MessageListResult) -> Void) {
        let page = self.page + 1
        loadData(at: page) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let models):
                self.models.append(contentsOf: models)
                self.page = page
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


// MARK: - DataSource

extension MessageTableViewModel {
    func numberOfModels() -> Int {
        return models.count
    }
    
    func item(at index: Int) -> BaseMessageModel {
        return models[index]
    }
}
