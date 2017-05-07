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
import SDWebImage

private let kTotalPageKey = "totalPage"

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

/// 帖子列表网络请求管理
class HiPDAThreadManager {
    /// 帖子列表
    fileprivate(set) var threads: [HiPDAThread]
    
    /// 当前最大页数
    fileprivate(set) var page: Int
    
    /// 总页数
    fileprivate(set) var totalPage: Int
    
    /// 论坛id
    let fid: Int
    
    /// 过滤id
    let typeid: Int
    
    /// 状态
    private var state = HiPDAThreadManagerState.idle
    
    /// disposeBag
    private var disposeBag = DisposeBag()
    
    init(fid: Int, typeid: Int, threads: [HiPDAThread]? = nil) {
        self.threads = threads ?? (CacheManager.threads.instance?.threads(forFid: fid, typeid: typeid) ?? [])
        self.page = 1
        self.fid = fid
        self.typeid = typeid
        self.totalPage = (CacheManager.threads.instance?.object(forKey: kTotalPageKey) as? NSNumber)?.intValue ?? 1
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
        let page = self.page
        fetchThreads(at: page + 1).subscribe { [weak self] event in
            self?.handleThreadsFetch(event: event, at: page + 1, state: .loadingMore, completion: completion)
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
        let userBlockSet = Set(Settings.shared.userBlockList)
        let totalPage = self.totalPage
        return Observable.create { observer in
            HiPDAProvider.request(.threads(fid: fid, typeid: typeid, page: page))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
                .mapGBKString()
                .do(onNext: { [weak self] htmlString in
                    guard let `self` = self, page == 1 else { return }
                    self.totalPage = try HtmlParser.totalPage(from: htmlString)
                })
                .map {
                    return try HtmlParser.threads(from: $0).filter {
                            /// 删除在用户黑名单中的帖子
                            return !userBlockSet.contains($0.user.name)
                        }.filter { thread in
                            /// 删除包含过滤关键词的帖子
                            for word in Settings.shared.threadAttentionWordList {
                                if thread.title.contains(word) {
                                    return false
                                }
                            }
                            return true
                        }
                }
                .do(onNext: { threads in
                    /// 添加到关注列表中
                    CacheManager.attention.instance?.addThreadsToAttention(threads: threads)
                    
                    if page == 1 {
                        /// 添加到缓存中
                        CacheManager.threads.instance?.setThreads(threads: threads, forFid: fid, typeid: typeid)
                        CacheManager.threads.instance?.setObject(totalPage as NSNumber, forKey: kTotalPageKey)
                    }
                    
                    /// 预加载用户头像
                    let urls = threads.map { $0.user.avatarImageURL }
                    SDWebImagePrefetcher.shared().prefetchURLs(urls)
                })
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
