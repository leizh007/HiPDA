//
//  PostViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import MJRefresh

typealias PostFetchCompletion = (PostResult) -> Void

/// view和model之间的桥梁
class PostViewModel {
    /// 总页数
    fileprivate var totalPage: Int {
        return manager.totalPage
    }
    
    /// 是否有更多的数据
    var hasMoreData: Bool {
        return manager.page < totalPage
    }
    fileprivate var manager: PostManager
        
    init(postInfo: PostInfo) {
        manager = PostManager(postInfo: postInfo)
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
            manager.loadFirstPage { [weak self] result in
                self?.handPostListResult(result, completion: completion)
            }
        } else {
            manager.loadPreviousPage { [weak self] result in
                self?.handPostListResult(result, completion: completion)
            }
        }
    }
    
    /// 加载更多的数据
    func loadMoreData(completion: @escaping PostFetchCompletion = { _ in }) {
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
        // TODO: - 帖子列表转换到html字符串
        //let userBlockSet = Set(Settings.shared.userBlockList)
        DispatchQueue.global(qos: .default).async {
            
        }
    }
}
