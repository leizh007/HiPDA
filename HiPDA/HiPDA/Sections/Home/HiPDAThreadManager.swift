//
//  HiPDAThreadManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Curry

typealias HiPDAThreadsFetchCompletion = (HiPDAThreadsResult) -> ()

/// 获取帖子
///
/// - idle: 空闲
/// - refreshing: 刷新
/// - loadingMore: 加载更多
private enum HiPDAThreadManagerState {
    case idle
    case refreshing
    case loadingMore
}

/// 帖子列表管理
class HiPDAThreadManager {
    /// 帖子列表
    fileprivate(set) var threads: [HiPDAThread]
    
    /// 当前最大页数
    fileprivate(set) var page: Int
    
    /// 论坛id
    let fid: Int
    
    /// 过滤id
    let typeid: Int
    
    /// 状态
    private var state = HiPDAThreadManagerState.idle
    
    /// disposeBag
    private var disposeBag = DisposeBag()
    
    init(threads: [HiPDAThread], page: Int, fid: Int, typeid: Int) {
        self.threads = threads
        self.page = page
        self.fid = fid
        self.typeid = typeid
    }
    
    /// 获取第一页帖子列表
    ///
    /// - Parameter completion: 返回帖子列表获取结果
    func firstPageThreads(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        disposeBag = DisposeBag()
        state = .refreshing
        fetchThreads(at: 1).subscribe { [weak self] event in
            self?.handleThreadsFetch(event: event, at: 1, state: .refreshing, completion: completion)
        }.disposed(by: disposeBag)
    }
    
    /// 获取下一页帖子列表
    ///
    /// - Parameter completion: 返回帖子列表获取结果
    func nextPageThreads(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        disposeBag = DisposeBag()
        state = .loadingMore
        fetchThreads(at: page + 1).subscribe { [weak self] event in
            self?.handleThreadsFetch(event: event, at: 1, state: .loadingMore, completion: completion)
        }.disposed(by: disposeBag)
    }
    
    /// 处理帖子列表获取的结果
    ///
    /// - Parameter event: 网络请求结果
    /// - Parameter page: 请求的帖子页码
    /// - Parameter state: 请求状态
    /// - Parameter completion: 返回帖子列表获取结果
    private func handleThreadsFetch(event: Event<HiPDAThreadsResult>, at page: Int, state: HiPDAThreadManagerState, completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        guard self.state == state else { return }
        self.state = .idle
        switch event {
        case let .next(result):
            if case let .success(threads) = result {
                self.page = page
                if page == 1 {
                    self.threads = threads
                } else {
                    self.threads.append(contentsOf: threads)
                }
            }
            completion(result)
        case let .error(error):
            completion(.failure(.unKnown(error.localizedDescription)))
        default:
            break
        }
    }
    
    /// 获取帖子列表
    ///
    /// - Parameter page: 页数
    /// - Returns: 返回帖子列表获取结果
    private func fetchThreads(at page: Int) -> Observable<HiPDAThreadsResult> {
        let fid = self.fid
        let typeid = self.typeid
        return Observable.create { observer in
            HiPDAProvider.request(.threads(fid: fid, typeid: typeid, page: page))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
                .mapGBKString()
                .map {
                    return try HtmlParser.threads(from: $0)
                }
                .observeOn(MainScheduler.instance)
                .subscribe { event in
                    switch event {
                    case let .next(threads):
                        observer.onNext(.success(threads))
                    case let .error(error):
                        let threadResultError: HiPDAThreadError = error is HtmlParserError ? .parseError(String(describing: error as! HtmlParserError)) : .unKnown(error.localizedDescription)
                        observer.onNext(.failure(threadResultError))
                    default:
                        break
                    }
                    observer.onCompleted()
            }
        }
    }
}
