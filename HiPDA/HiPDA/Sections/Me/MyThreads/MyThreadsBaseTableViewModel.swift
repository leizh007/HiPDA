//
//  MyThreadsBaseTableViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class MyThreadsBaseTableViewModel {
    var disposeBag = DisposeBag()
    var models = [MyThreadsBaseModel]()
    var page = 1
    var maxPage = 1
    var hasData: Bool {
        return models.count > 0
    }
    var hasMoreData: Bool {
        return page < maxPage
    }
    
    func numberOfItems() -> Int {
        return models.count
    }
    
    func loadFirstPage(completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        self.page = 1
        let page = 1
        load(page: page) { [weak self] result in
            guard let `self` = self, page == `self`.page else { return }
            switch result {
            case let .success((models: models, maxPage: maxPage)):
                self.models = models
                self.maxPage = maxPage
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func loadNextPage(completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        self.page += 1
        let page = self.page
        load(page: page) { [weak self] result in
            guard let `self` = self, page == `self`.page else { return }
            switch result {
            case let .success((models: models, maxPage: maxPage)):
                self.models.append(contentsOf: models)
                self.maxPage = maxPage
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func transform(html: String) throws -> [MyThreadsBaseModel] {
        fatalError("Must be overrided!")
    }
    
    func api(at page: Int) -> HiPDA.API {
        fatalError("Must be overrided!")
    }
    
    fileprivate func load(page: Int, completion: @escaping (HiPDA.Result<(models: [MyThreadsBaseModel], maxPage: Int), NSError>) -> Void) {
        disposeBag = DisposeBag()
        let transform = self.transform
        HiPDAProvider.request(self.api(at: page))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { (try transform($0), try HtmlParser.totalPage(from: $0)) }
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let (models, maxPage)):
                    completion(.success((models: models, maxPage: maxPage)))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    func jumpURL(at index: Int) -> String {
        fatalError("Must be overrided!")
    }
}
