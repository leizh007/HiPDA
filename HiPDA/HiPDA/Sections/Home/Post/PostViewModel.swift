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

typealias PostFetchCompletion = (PostResult) -> Void

enum PostViewStatus {
    case idle
    case loadingFirstPage
    case loadingPreviousPage
    case loadingNextPage
}

/// view和model之间的桥梁
class PostViewModel {
    var status = PostViewStatus.idle
    var postInfo: PostInfo! {
        didSet {
            manager.postInfo = postInfo
        }
    }
    
    let emptyHtml: String = HtmlManager.html(with: "")
    
    /// 总页数
    fileprivate var totalPage: Int {
        return manager.totalPage
    }
    
    /// 是否有更多的数据
    var hasMoreData: Bool {
        return manager.page < totalPage
    }
    
    var hasData: Bool {
        return !manager.pidSet.isEmpty
    }
    
    fileprivate var manager: PostManager
        
    init(postInfo: PostInfo) {
        manager = PostManager(postInfo: postInfo)
    }
    
    func shouldAutoLoadImage(url: String, completion: @escaping (Bool) -> Void) {
        if Settings.shared.autoLoadImageViaWWAN || NetworkReachabilityManager.shared.isReachableOnEthernetOrWiFi {
            completion(true)
            return
        }
        let urlString = url.replacingOccurrences(of: C.URL.HiPDA.image, with: "")
                           .replacingOccurrences(of: C.URL.HiPDA.imagePlaceholder, with: "")
        console(message: urlString)
        SDImageCache.shared().queryCacheOperation(forKey: urlString) { (image, data, _) in
            completion(image != nil || data != nil)
        }
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
                content += "<div class=\"title\">\(title)</div>"
            }
            for post in posts {
                let userName = isEnabledUserRemark ? (userRemarkDictionary[post.user.name] ?? post.user.name) : post.user.name
                let postContent = userBlockSet.contains(post.user.name) ? "<div class=\"userblock\">该用户已被您屏蔽！</div>" : post.content
                content += "<div class=\"post\" id=\"post_\(post.id)\"><div class=\"header\"><div class=\"user\" onclick=\"userClicked(this)\"><span><img class=\"avatar\" src=\"\(post.user.avatarImageURL.absoluteString)\" alt=\"\"/></span><span class=\"username\">\(userName)</span><span class=\"uid\">\(post.user.uid)</span></div><div class><span class=\"time\">\(post.time)</span><span class=\"floor\">\(post.floor)#</span></div></div><div class=\"content\">\(postContent)</div></div>"
            }
            let html = HtmlManager.html(with: content)
            DispatchQueue.main.async {
                completion(.success(html))
            }
        }
    }
}
