//
//  SearchUserThreadsViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

typealias SearchUserThreadsResult = HiPDA.Result<Void, NSError>

class SearchUserThreadsViewModel {
    var disposeBag = DisposeBag()
    let user: User
    fileprivate var models = [SearchUserThreadModel]()
    fileprivate var page = 1
    fileprivate var totalPage = 1
    fileprivate var searchId: Int?
    init(user: User) {
        self.user = user
    }
    
    var hasData: Bool {
        return !models.isEmpty
    }
    
    var hasMoreData: Bool {
        return page < totalPage
    }
}

// MARK: - Data Load

extension SearchUserThreadsViewModel {
    func loadNewData(completion: @escaping (SearchUserThreadsResult) -> Void) {
        let page = 1
        loadData(at: page) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let models):
                self.models = models
                self.page = page
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadMoreData(completion: @escaping (SearchUserThreadsResult) -> Void) {
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
    
    private func loadData(at page: Int, completion: @escaping (HiPDA.Result<[SearchUserThreadModel], NSError>) -> Void) {
        disposeBag = DisposeBag()
        guard let searchId = self.searchId else {
            getSearchId { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(_):
                    self.loadData(at: page, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        HiPDAProvider.request(.searchUserThreads(searchId: searchId, page: page))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { try HtmlParser.searchUserThreads(from: $0) }
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let models):
                    completion(.success(models))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    private func getSearchId(completion: @escaping (SearchUserThreadsResult) -> Void) {
        let searchIdFetcherror = NSError(domain: "HiPDA-SearchUserThreads", code: -1, userInfo: [NSLocalizedDescriptionKey: "获取用户发表的帖子信息出错"])
        HiPDAProvider.manager.delegate.taskWillPerformHTTPRedirectionWithCompletion = { [weak self] (sesseion, task, response, request, completionBlock) in
            DispatchQueue.main.async {
                HiPDAProvider.manager.delegate.taskWillPerformHTTPRedirectionWithCompletion = nil
                guard let urlString = request.url?.absoluteString else {
                    completion(.failure(searchIdFetcherror))
                    return
                }
                do {
                    self?.searchId = try HtmlParser.searchId(from: urlString)
                    completion(.success(()))
                } catch {
                    completion(.failure(error as NSError))
                }
            }
        }
        HiPDAProvider.request(.redirect("/forum/search.php?srchuid=\(user.uid)&srchfid=all&srchfrom=0&searchsubmit=yes")).asObservable()
            .subscribe(onNext: { response in
                completion(.failure(searchIdFetcherror))
        }).disposed(by: disposeBag)
    }
}

// MARK: - DataSource

extension SearchUserThreadsViewModel {
    func numberOfModels() -> Int {
        return models.count
    }
    
    func model(at index: Int) -> SearchUserThreadModel {
        return models[index]
    }
}
