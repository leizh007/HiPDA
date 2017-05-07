//
//  HomeViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/4/25.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel {
    var forumNames: [String] {
        return Settings.shared.activeForumNameList
    }
    
    private var _selectedForumName: String = Settings.shared.activeForumNameList.first ?? ""
    
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
        return Status.calledNumber == 1 || oldForumName != newForumName
    }
    
    var hasData: Bool {
        return managerDic[selectedForumName] != nil && managerDic[selectedForumName]!.threads.count > 0
    }
    
    fileprivate var managerDic = [String: HiPDAThreadManager]()
    
    /// 是否可以加载下一页的数据，当达到最后一页时不能再加载了
    var canLoadMoreData: Bool {
        return managerDic[selectedForumName] != nil &&
            managerDic[selectedForumName]!.totalPage > managerDic[selectedForumName]!.page
    }
    
    fileprivate var manager: HiPDAThreadManager {
        let manager: HiPDAThreadManager
        if managerDic[selectedForumName] != nil {
            manager = managerDic[selectedForumName]!
        } else {
            manager = HiPDAThreadManager(fid: ForumManager.fid(ofForumName: selectedForumName),
                                         typeid: 0)
        }
        
        return manager
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning(application:)),
                                               name: .UIApplicationDidReceiveMemoryWarning,
                                               object: nil)
    }
    
    @objc func didReceiveMemoryWarning(application: UIApplication) {
        let manager = self.manager
        managerDic = [:]
        managerDic[selectedForumName] = manager
    }
}

// MARK: - DataSource

extension HomeViewModel {
    func numberOfThreads() -> Int {
        return managerDic[selectedForumName]?.threads.count ?? 0
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
        manager.firstPageThreads(completion: completion)
    }
    
    /// 网络加载数据
    func refreshData(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        manager.firstPageThreads(completion: completion)
    }
    
    /// 加载下一页数据
    func loadMoreData(completion: @escaping HiPDAThreadsFetchCompletion = { _ in }) {
        manager.nextPageThreads(completion: completion)
    }
}
