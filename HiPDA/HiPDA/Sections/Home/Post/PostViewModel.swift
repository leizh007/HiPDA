//
//  PostViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import MJRefresh
import SDWebImage
import RxSwift

typealias PostFetchCompletion = (PostResult) -> Void

enum PostViewStatus {
    case idle
    case loadingFirstPage
    case loadingPreviousPage
    case loadingNextPage
    case loadingFirstEntrance
}

/// view和model之间的桥梁
class PostViewModel {
    fileprivate var disposeBag = DisposeBag()
    var status = PostViewStatus.idle
    var postInfo: PostInfo! {
        set {
            manager.postInfo = newValue
        }
        
        get {
            return manager.postInfo
        }
    }
    
    var isPostInFavoriteList = false
    var isPostInAttentionList = false
    
    /// 总页数
    var totalPage: Int {
        return manager.totalPage
    }
    
    /// 是否有更多的数据
    var hasMoreData: Bool {
        return manager.page < totalPage
    }
    
    var hasData: Bool {
        return !manager.pidSet.isEmpty
    }
    
    var fid: Int? {
        return manager.fid
    }
    
    func contains(pid: Int?) -> Bool {
        return pid == nil ? true : manager.pidSet.contains(pid!)
    }
    
    fileprivate var manager: PostManager
        
    init(postInfo: PostInfo) {
        manager = PostManager(postInfo: postInfo)
    }
    
    func shouldAutoLoadImage(completion: @escaping (Bool) -> Void) {
        completion(Settings.shared.autoLoadImageViaWWAN || NetworkReachabilityManager.shared.isReachableOnEthernetOrWiFi)
    }
    
    func loadImage(url: String, completion: @escaping (Error?) -> Void) {
        SDWebImageManager.shared().loadImage(with: URL(string: url), options: [], progress: nil) { (_, _, error, _, _, _) in
            completion(error)
        }
    }
    
    static func skinURL(url: String) -> String {
        if !url.contains("http") && url.contains("attachment.php?aid=") {
            return "https://www.hi-pda.com/forum/\(url)"
        }
        return url
    }
    
    func userOfPid(_ pid: Int) -> User? {
        return manager.userOfPid(pid)
    }
}

// MARK: - Header Titles

extension PostViewModel {
    /// webView的下拉刷新header标题
    ///
    /// - Parameter state: 下拉刷新状态
    /// - Returns: 标题
    func headerTitle(for state: MJRefreshState) -> String {
        switch state {
        case .idle:
            return manager.page == 1 ? "下拉可以刷新" : "下拉加载上一页"
        case .pulling:
            return manager.page == 1 ? "松开立即刷新" : "松开立即加载上一页"
        case .refreshing:
            return manager.page == 1 ? "正在刷新数据中..." : "正在加载数据中..."
        case .willRefresh:
            return ""
        case .noMoreData:
            return ""
        }
    }
    
    /// webView的上拉加载footer标题
    ///
    /// - Parameter state: 上拉加载状态
    /// - Returns: 标题
    func footerTitle(for state: MJRefreshState) -> String {
        switch state {
        case .idle:
            return "上拉可以加载下一页"
        case .pulling:
            return "松开立即加载下一页"
        case .refreshing:
            return "正在加载下一页的数据..."
        case .willRefresh:
            return ""
        case .noMoreData:
            return "已经全部加载完毕"
        }
    }
}

// MARK: - Data Load

extension PostViewModel {    
    func handlePostSendCompletion(_ html: String, completion: @escaping PostFetchCompletion = { _ in }) {
        status = .idle
        manager.handlePostSendCompletion(html) { [weak self] result in
            self?.handPostListResult(result, completion: completion)
        }
    }
    
    func loadData(completion: @escaping PostFetchCompletion = { _ in }) {
        status = .loadingFirstEntrance
        manager.load(postInfo: manager.postInfo) { [weak self] result in
            self?.handPostListResult(result, completion: completion)
        }
    }
    
    /// 获取新数据
    func loadNewData(completion: @escaping PostFetchCompletion = { _ in }) {
        if manager.page == 1 {
            status = .loadingFirstPage
            manager.loadFirstPage { [weak self] result in
                self?.handPostListResult(result, completion: completion)
            }
        } else {
            status = .loadingPreviousPage
            manager.loadPreviousPage { [weak self] result in
                self?.handPostListResult(result, completion: completion)
            }
        }
    }
    
    /// 加载更多的数据
    func loadMoreData(completion: @escaping PostFetchCompletion = { _ in }) {
        status = .loadingNextPage
        manager.loadNextPage { [weak self] result in
            self?.handPostListResult(result, completion: completion)
        }
    }
    
    /// 处理Post列表结果
    fileprivate func handPostListResult(_ result: PostListResult, completion: @escaping PostFetchCompletion = { _ in }) {
        switch result {
        case .success(let value):
            parsePosts(value.posts, title: value.title, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    /// Post列表到html的转换
    fileprivate func parsePosts(_ posts: [Post], title: String? = nil, completion: @escaping PostFetchCompletion = { _ in }) {
        let userBlockSet = Set(Settings.shared.userBlockList)
        let isEnabledUserRemark = Settings.shared.isEnabledUserRemark
        let userRemarkDictionary = Settings.shared.userRemarkDictionary
        DispatchQueue.global(qos: .userInteractive).async {
            var content = ""
            if let title = title {
                content += "<div class=\"title\" id=\"title\">\(title)</div>"
            }
            for post in posts {
                let userName = isEnabledUserRemark ? (userRemarkDictionary[post.user.name] ?? post.user.name) : post.user.name
                let postContent = userBlockSet.contains(post.user.name) ? "<div class=\"userblock\">该用户已被您屏蔽！</div>" : post.content
                content += "<div class=\"post\" id=\"post_\(post.id)\" onclick=\"postClicked(this); event.stopPropagation();\"><div class=\"header\"><div class=\"user\" onclick=\"userClicked(this); event.stopPropagation();\"><span><img class=\"avatar\" src=\"\(post.user.avatarImageURL.absoluteString)\" alt=\"\"/></span><span class=\"username\">\(userName)</span><span class=\"uid\">\(post.user.uid)</span></div><div class><span class=\"time\">\(post.time)</span><span class=\"floor\">\(post.floor)#</span></div></div><div class=\"content\">\(postContent)</div></div>"
            }
            let html = HtmlManager.html(with: content)
            DispatchQueue.main.async {
                completion(.success(html))
            }
        }
    }
    
    func reload(completion: @escaping PostFetchCompletion = { _ in }) {
        parsePosts(manager.posts, title: manager.title, completion: completion)
    }
}

// MARK: - NetWork Request

typealias FavoriteAndAttentionCompletion = (HiPDA.Result<String, FavoriteAndAttentionError>) -> Void

extension PostViewModel {
    func favoriteButtonPressed(doing: @escaping (String) -> Void, completion: @escaping FavoriteAndAttentionCompletion) {
        if !isPostInFavoriteList {
            doing("正在加入收藏列表...")
            request(with: .addToFavorites(tid: postInfo.tid)) { [weak self] result in
                switch result {
                case .success(_):
                    self?.isPostInFavoriteList = true
                    completion(.success("收藏成功!"))
                case .failure(let error):
                    completion(.failure(.unKnown(error.localizedDescription)))
                }
            }
        } else {
            doing("正在取消收藏...")
            delete(type: .favorites, tid: manager.postInfo.tid) { [weak self] result in
                switch result {
                case .success(_):
                    self?.isPostInFavoriteList = false
                    completion(.success("取消收藏!"))
                case .failure(let error):
                    completion(.failure(.unKnown(error.localizedDescription)))
                }
            }
        }
    }
    
    func attentionButtonPressed(doing: @escaping (String) -> Void, completion: @escaping FavoriteAndAttentionCompletion) {
        if !isPostInAttentionList {
            doing("正在加入关注列表...")
            request(with: .addToAttentions(tid: postInfo.tid)) { [weak self] result in
                switch result {
                case .success(_):
                    self?.isPostInAttentionList = true
                    completion(.success("关注成功!"))
                case .failure(let error):
                    completion(.failure(.unKnown(error.localizedDescription)))
                }
            }
        } else {
            doing("正在取消关注...")
            delete(type: .attention, tid: manager.postInfo.tid) { [weak self] result in
                switch result {
                case .success(_):
                    self?.isPostInAttentionList = false
                    completion(.success("取消关注!"))
                case .failure(let error):
                    completion(.failure(.unKnown(error.localizedDescription)))
                }
            }
        }
    }
        
    fileprivate func request(with api: HiPDA.API, completion: @escaping FavoriteAndAttentionCompletion) {
        disposeBag = DisposeBag()
        HiPDAProvider.request(api)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .observeOn(MainScheduler.instance).subscribe { event in
                switch event {
                case let .next(html):
                    do {
                        let msg = try PostViewModel.favoriteMessage(from: html)
                        completion(.success(msg))
                    } catch {
                        completion(.failure(.unKnown(error.localizedDescription)))
                    }
                case let .error(error):
                    completion(.failure(.unKnown(error.localizedDescription)))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func delete(type: FavoritesAndAttentionType, tid: Int, completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        let formhashPath: String
        switch type {
        case .favorites:
            formhashPath = "/forum/my.php?item=favorites&type=thread"
        case .attention:
            formhashPath = "/forum/my.php?item=attention&type=thread"
        }
        NetworkUtilities.formhash(from: formhashPath) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let formhash):
                let api: HiPDA.API
                switch type {
                case .favorites:
                    api = .deleteFavorites(tids: [tid], formhash: formhash)
                case .attention:
                    api = .deleteAttentions(tids: [tid], formhash: formhash)
                }
                HiPDAProvider.request(api)
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .mapGBKString()
                    .map { try HtmlParser.alertInfo(from: $0) }
                    .observeOn(MainScheduler.instance)
                    .subscribe { event in
                        switch event {
                        case .next(let info):
                            completion(.success(info))
                        case .error(let error):
                            completion(.failure(error as NSError))
                        default:
                            break
                        }
                    }.disposed(by: self.disposeBag)
            }
        }
    }
    
    fileprivate static func favoriteMessage(from html: String) throws -> String {
        let result = try Regex.firstMatch(in: html, of: "<root><!\\[CDATA\\[([^<]+)<br")
        guard result.count == 2 && !result[1].isEmpty else { throw FavoriteAndAttentionError.unableToGetFavoriteMsg }
        return result[1]
    }
}

// MARK: - Error

enum FavoriteAndAttentionError: Error {
    case unableToGetFavoriteMsg
    case unKnown(String)
}

extension FavoriteAndAttentionError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unableToGetFavoriteMsg:
            return "获取返回结果出错"
        case let .unKnown(value):
            return value
        }
    }
}

extension FavoriteAndAttentionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToGetFavoriteMsg:
            return "获取返回结果出错"
        case let .unKnown(value):
            return value
        }
    }
}
