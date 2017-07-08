//
//  FavoritesAndAtttentionBaseViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

typealias FavoritesAndAttentionResult = HiPDA.Result<Void, NSError>

enum FavoritesAndAttentionType: String {
    case favorites
    case attention
}

class FavoritesAndAttentionBaseViewModel {
    fileprivate var disposeBag = DisposeBag()
    fileprivate var page = 1
    fileprivate var maxPage = 1
    fileprivate var models = [FavoritesAndAttentionBaseModel]()
    let type: FavoritesAndAttentionType
    init(type: FavoritesAndAttentionType) {
        self.type = type
    }
    
    var hasData: Bool {
        return models.count > 0
    }
    
    var hasMoreData: Bool {
        return page < maxPage
    }
    
    func transform(html: String) throws -> [FavoritesAndAttentionBaseModel] {
        fatalError("Must be overrided!")
    }
    
    func loadFirstPage(completion: @escaping (FavoritesAndAttentionResult) -> Void) {
        self.page = 1
        load(page: self.page) { [weak self ] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let (models: models, maxPage: maxPage)):
                self.models = models
                self.maxPage = maxPage
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadNextPage(completion: @escaping (FavoritesAndAttentionResult) -> Void) {
        self.page += 1
        load(page: self.page) { [weak self ] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let (models: models, maxPage: maxPage)):
                self.models.append(contentsOf: models)
                self.maxPage = maxPage
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    fileprivate func load(page: Int, completion: @escaping (HiPDA.Result<(models: [FavoritesAndAttentionBaseModel], maxPage: Int), NSError>) -> Void) {
        disposeBag = DisposeBag()
        let api: HiPDA.API
        switch type {
        case .favorites:
            api = .favorites(page: page)
        case .attention:
            api = .attention(page: page)
        }
        let transform = self.transform(html:)
        HiPDAProvider.request(api)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { html -> (models: [FavoritesAndAttentionBaseModel], maxPage: Int) in
                return (models: try transform(html), maxPage: try HtmlParser.totalPage(from: html))
            }
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case let .next(models: models, maxPage: maxPage):
                    completion(.success((models: models, maxPage: maxPage)))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - DataSource

extension FavoritesAndAttentionBaseViewModel {
    func numberOfItems() -> Int {
        return models.count
    }
    
    func model(at index: Int) -> FavoritesAndAttentionBaseModel {
        return models[index]
    }
    
    func jumpURL(at index: Int) -> String {
        let tid = model(at: index).tid
        return "https://www.hi-pda.com/forum/viewthread.php?tid=\(tid)&extra=page%3D1"
    }
}
