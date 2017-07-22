//
//  PostManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

typealias PostListFetchCompletion = (PostListResult) -> Void

/// 数据的网络请求管理
class PostManager {
    var pidSet = Set<Int>()
    var posts = [Post]()
    var fid: Int? = nil
    fileprivate var disposeBag = DisposeBag()
    var postInfo: PostInfo {
        didSet {
            title = nil
            fid = nil
        }
    }
    init(postInfo: PostInfo) {
        self.postInfo = postInfo
    }
    
    var title: String?
    
    /// 总页数
    fileprivate(set) var totalPage = Int.max
    
    /// 当前页数
    var page: Int {
        return postInfo.page
    }
    
    func userOfPid(_ pid: Int) -> User? {
        return posts.filter { $0.id == pid }.first?.user
    }
    
    /// 加载第一页数据
    func loadFirstPage(completion: @escaping PostListFetchCompletion = { _ in }) {
        let oldPostInfo = postInfo
        postInfo = PostInfo.lens.page.set(1, postInfo)
        load(postInfo: postInfo) { [weak self] result in
            if case .failure(_) = result {
                self?.postInfo = oldPostInfo
            }
            completion(result)
        }
    }
    
    /// 加载前一页数据
    func loadPreviousPage(completion: @escaping PostListFetchCompletion = { _ in }) {
        let oldPostInfo = postInfo
        postInfo = PostInfo.lens.page.set(postInfo.page - 1, postInfo)
        load(postInfo: postInfo) { [weak self] result in
            if case .failure(_) = result {
                self?.postInfo = oldPostInfo
            }
            completion(result)
        }
    }
    
    /// 加载后一页数据
    func loadNextPage(completion: @escaping PostListFetchCompletion = { _ in }) {
        let oldPostInfo = postInfo
        postInfo = PostInfo.lens.page.set(postInfo.page + 1, postInfo)
        load(postInfo: postInfo) { [weak self] result in
            if case .failure(_) = result {
                self?.postInfo = oldPostInfo
            }
            completion(result)
        }
    }
    
    /// 加载指定postInfo的数据
    func load(postInfo: PostInfo, completion: @escaping PostListFetchCompletion = { _ in }) {
        disposeBag = DisposeBag()
        
        var totalPage = self.totalPage
        var title = self.title
        let uid = postInfo.authorid
        var fid = self.fid
        HiPDAProvider.request(.posts(postInfo))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .do(onNext: { html in
                totalPage = try HtmlParser.totalPage(from: html)
                if postInfo.page == 1 {
                    if title == nil {
                        do {
                            title = try HtmlParser.postTitle(from: html)
                        } catch {
                            if uid == nil {
                                throw error
                            }
                        }
                    }
                } else {
                    title = nil
                }
                fid = try HtmlParser.fid(from: html)
            })
            .map(HtmlParser.posts(from:))
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let `self` = self, postInfo == `self`.postInfo else { return }
                self.totalPage = totalPage
                if self.postInfo.page > self.totalPage {
                    self.postInfo = PostInfo.lens.page.set(self.totalPage, self.postInfo)
                }
                self.title = title
                switch event {
                case let .next(posts):
                    self.pidSet = Set(posts.map { $0.id })
                    self.posts = posts
                    self.fid = fid
                    completion(.success((title: title, posts: posts)))
                case let .error(error):
                    self.fid = nil
                    let postsResultError: PostError = error is HtmlParserError ? .parseError(String(describing: error as! HtmlParserError)) : .unKnown(error.localizedDescription)
                    completion(.failure(postsResultError))
                case .completed:
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    func handlePostSendCompletion(_ html: String, completion: @escaping PostListFetchCompletion = { _ in }) {
        guard let posts = try? HtmlParser.posts(from: html),
            let totalPage = try? HtmlParser.totalPage(from: html),
            let fid = try? HtmlParser.fid(from: html) else { return }
        self.totalPage = totalPage
        self.pidSet = Set(posts.map { $0.id })
        self.posts = posts
        postInfo = PostInfo.lens.page.set(totalPage, postInfo)
        self.fid = fid
        var title: String? = nil
        if totalPage == 1 {
            title = try? HtmlParser.postTitle(from: html)
            self.title = title
        } else {
            self.title = nil
        }
        completion(.success((title: title, posts: posts)))
    }
}
