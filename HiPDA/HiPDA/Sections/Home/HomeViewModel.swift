//
//  HomeViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/4/25.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

/// 帖子列表过时时间为一小时
private let kThreadsOutOfDateTimeInterval = 60.0 * 60.0

class HomeViewModel {
    /// 论坛列表
    var forumNames: [String] {
        return Settings.shared.activeForumNameList
    }
    
    private var _selectedForumName: String = Settings.shared.activeForumNameList.first ?? ""
    
    /// 当前选择的论坛名称
    var selectedForumName: String {
        get {
            if !forumNames.contains(_selectedForumName) {
                _selectedForumName = forumNames.first ?? ""
            }
            return _selectedForumName
        }
        
        set {
            _selectedForumName = newValue
        }
    }
    
    /// 当钱选中的论坛版块名称不在论坛列表中
    var shouldRefreshData: Bool {
        struct Status {
            static var calledNumber = 0
        }
        Status.calledNumber += 1
        let oldForumName = _selectedForumName
        let newForumName = selectedForumName
        return Status.calledNumber == 1 || oldForumName != newForumName || !hasData
    }
    
    /// 是否有数据
    var hasData: Bool {
        return managerDic[selectedForumName] != nil && managerDic[selectedForumName]!.threads.count > 0
    }
    
    fileprivate var managerDic = [String: HiPDAThreadManager]()
    
    /// 是否可以加载下一页的数据，当达到最后一页时不能再加载了
    var canLoadMoreData: Bool {
        return managerDic[selectedForumName] != nil &&
            managerDic[selectedForumName]!.totalPage > managerDic[selectedForumName]!.page
    }
    
    /// 帖子数据是否过时
    var isThreadsOutOfDate: Bool {
        return Date().timeIntervalSince1970 - manager.timeStamp > kThreadsOutOfDateTimeInterval
    }
    
    fileprivate var manager: HiPDAThreadManager {
        let manager: HiPDAThreadManager
        if managerDic[selectedForumName] != nil {
            manager = managerDic[selectedForumName]!
        } else {
            manager = HiPDAThreadManager(fid: ForumManager.fid(ofForumName: selectedForumName),
                                         typeid: 0)
            managerDic[selectedForumName] = manager
        }
        
        return manager
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning),
                                               name: .UIApplicationDidReceiveMemoryWarning,
                                               object: nil)
    }
    
    /// 收到内存警告
    @objc func didReceiveMemoryWarning() {
        let manager = self.manager
        managerDic = [:]
        managerDic[selectedForumName] = manager
    }
    
    /// 阅读帖子
    ///
    /// - Parameter index: 帖子下标
    func readThread(at index: Int) {
        guard let thread = manager.threads.safe[index] else { return }
        CacheManager.threadsReadHistory.instance?.addThread(thread)
    }
    
    /// 删除帖子
    ///
    /// - Parameter index: 帖子所在的下标
    func deleteThread(at index: Int) {
        manager.deleteThread(at: index)
    }
    
    /// 将该帖子的作者加到黑名单中
    ///
    /// - Parameter index: 帖子所在的下标
    func addThreadUserToUserBlock(at index: Int) {
        guard let thread = manager.threads.safe[index] else { return }
        Settings.shared.userBlockList.append(thread.user.name)
        deleteThread(at: index)
    }
}

// MARK: - DataSource

extension HomeViewModel {
    /// 帖子数目
    ///
    /// - Returns: 帖子数目
    func numberOfThreads() -> Int {
        return managerDic[selectedForumName]?.threads.count ?? 0
    }
    
    /// 返回指定下标的帖子模型
    ///
    /// - Parameter index: 下标
    /// - Returns: 下标所在的帖子模型
    func threadModel(at index: Int) -> HomeThreadModel? {
        guard let thread = manager.threads.safe[index] else { return nil }
        let userName = Settings.shared.isEnabledUserRemark ? (Settings.shared.userRemarkDictionary[thread.user.name] ?? thread.user.name) : thread.user.name
        return HomeThreadModel(avatarImageURL: thread.user.avatarImageURL,
                               userName: userName,
                               replyCount: thread.replyCount,
                               readCount: thread.readCount,
                               timeString: thread.postTime.descriptionTimeStringForThread,
                               title: thread.title)
    }
}

// MARK: - 加载数据相关

extension HomeViewModel {
    /// 加载数据，先从缓存中查找，缓存中没有再从网络加载
    func loadData(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        guard numberOfThreads() == 0 else {
            completion(.success([]))
            return
        }
        if manager.threads.count > 0 {
            completion(.success([]))
            return
        }
        let fid = manager.fid
        manager.firstPageThreads { [weak self] result in
            guard let `self` = self, fid == `self`.manager.fid else { return }
            completion(result)
        }
    }
    
    /// 网络加载数据
    func refreshData(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        let fid = manager.fid
        manager.firstPageThreads { [weak self] result in
            guard let `self` = self, fid == `self`.manager.fid else { return }
            completion(result)
        }
    }
    
    /// 加载下一页数据
    func loadMoreData(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        let fid = manager.fid
        manager.nextPageThreads { [weak self] result in
            guard let `self` = self, fid == `self`.manager.fid else { return }
            completion(result)
        }
    }
}
