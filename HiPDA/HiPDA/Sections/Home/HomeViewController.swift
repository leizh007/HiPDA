//
//  HomeViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import UITableView_FDTemplateLayoutCell
import Perform

/// 主页的ViewController
class HomeViewController: BaseViewController {
    /// 是否展示登录成功的提示信息
    fileprivate var showLoginSuccessInformation = true
    
    /// viewModel
    fileprivate var viewModel = HomeViewModel()
    
    /// 标题view
    @IBOutlet fileprivate var titleView: HomeNavigationBarTitleView!
    
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    /// 论坛名称
    fileprivate var forumName: String {
        get {
            return viewModel.selectedForumName
        }
        
        set {
            refreshData.onNext(())
            viewModel.selectedForumName = newValue
            titleView.title = newValue
        }
    }
    
    /// 加载数据
    fileprivate let refreshData = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleLoginStatue()
        handlAutoRefreshData()
        titleView.delegate = self
        if #available(iOS 10.0, *) {
            tableView.prefetchDataSource = self
        }
        tableView.status = .normal
        tableView.hasRefreshHeader = true
        tableView.hasLoadMoreFooter = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(homeViewControllerTabRepeatedSelected), name: .HomeViewControllerTabRepeatedSelected, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func homeViewControllerTabRepeatedSelected() {
        guard tableView.status == .normal else { return }
        if tableView.contentOffset.y == 0 {
            tableView.refreshing()
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        titleView.title = viewModel.selectedForumName
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "home_new_thread"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(newThreadButtonPressed(_:)))
    }
}

// MARK: - Button Action

extension HomeViewController {
    func newThreadButtonPressed(_ sender: UIBarButtonItem) {
        let newThreadVC = NewThreadViewController.load(from: .home)
        newThreadVC.type = .new(fid: ForumManager.fid(ofForumName: forumName))
        let nav = UINavigationController(rootViewController: newThreadVC)
        nav.transitioningDelegate = self
        present(nav, animated: true, completion: nil)
    }
}

// MARK: - AccountStatus 

extension HomeViewController {
    /// 处理登陆相关view展示
    fileprivate func handleLoginStatue() {
        if Settings.shared.lastLoggedInAccount != nil {
            self.showPromptInformation(of: .loading("正在登录..."))
        } else {
            self.showLoginSuccessInformation = false
        }
        
        Driver.combineLatest(EventBus.shared.activeAccount, viewDidAppear.asDriver()) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .drive(onNext: { [weak self] (result) in
                guard let `self` = self, let result = result else { return }
                self.hidePromptInformation()
                switch result {
                case .success(_):
                    if self.showLoginSuccessInformation {
                        self.showPromptInformation(of: .success("登录成功"))
                        self.showLoginSuccessInformation = false
                    }
                case .failure(let error):
                    self.showPromptInformation(of: .failure("\(error)"))
                    self.showLoginSuccessInformation = false
                }
            }).addDisposableTo(disposeBag)
    }
}

// MARK: - Data Refresh

extension HomeViewController {
    /// 处理数据自动刷新相关
    fileprivate func handlAutoRefreshData() {
        viewDidAppear.asObservable()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                if self?.viewModel.shouldRefreshData ?? false {
                    self?.refreshView()
                }
        }).disposed(by: disposeBag)
        
        /// 只有当界面出现和用户都登陆后才能开始加载数据
        Driver.combineLatest(refreshData.asDriver(onErrorJustReturn: ()), EventBus.shared.activeAccount) { ($0, $1) }
            .debounce(0.1)
            .filter { $0.1 != nil }
            .map { $0.1! }
            .filter { result in
                switch result {
                case .success(_):
                    return true
                case .failure(_):
                    return false
                }
            }.withLatestFrom(viewDidAppear.asDriver())
            .filter { $0 }
            .drive(onNext: { [weak self] value in
                guard let `self` = self else { return }
                self.tableView.endRefreshing()
                self.tableView.resetNoMoreData()
                self.tableView.endLoadMore()
                if self.viewModel.hasData {
                    self.tableView.reloadData()
                    CATransaction.begin()
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.tableView.status = .normal
                    CATransaction.setCompletionBlock {
                        if self.viewModel.isThreadsOutOfDate {
                            self.tableView.refreshing()
                        }
                    }
                    CATransaction.commit()
                } else {
                    self.tableView.status = .loading
                    self.viewModel.loadData { result in
                        self.handleDataLoadResult(result)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 更新view
    fileprivate func refreshView() {
        let name = forumName
        forumName = name
    }
    
    /// 处理刷新数据的结果
    ///
    /// - Parameter result: 获取帖子列表的结果
    fileprivate func handleDataLoadResult(_ result: HiPDAThreadsResult) {
        switch result {
        case .success(_):
            tableView.reloadData()
            if self.viewModel.numberOfThreads() > 0 {
                tableView.status = .normal
                CATransaction.begin()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                CATransaction.setCompletionBlock {
                    if self.viewModel.isThreadsOutOfDate {
                        self.tableView.refreshing()
                    }
                }
                CATransaction.commit()
            } else {
                self.tableView.status = .noResult
            }
        case .failure(let error):
            tableView.status = .tapToLoad
            showPromptInformation(of: .failure("\(error)"))
        }
    }
}

// MARK: - HomeNavigationBarTitleViewDelegate

extension HomeViewController: HomeNavigationBarTitleViewDelegate {
    func titleViewClicked(titleView: HomeNavigationBarTitleView) {
        guard let forumNameSelectionViewController = storyboard?.instantiateViewController(withIdentifier: ForumNameSelectionViewController.identifier) as? ForumNameSelectionViewController else { return }
        forumNameSelectionViewController.modalPresentationStyle = .popover
        forumNameSelectionViewController.preferredContentSize = CGSize(width: 225, height: 264) // 200跟titleView的最大宽度差不多，264 = 6 * cell的高度44.0
        forumNameSelectionViewController.popoverPresentationController?.sourceView = titleView
        let sourceRect = CGRect(x: 0, y: 0, width: titleView.bounds.size.width, height: 22.5)
        forumNameSelectionViewController.popoverPresentationController?.sourceRect = sourceRect // 为了让popOver的上边沿和navigationBar的下边沿对齐
        forumNameSelectionViewController.popoverPresentationController?.backgroundColor = .groupTableViewBackground
        forumNameSelectionViewController.popoverPresentationController?.delegate = self
        forumNameSelectionViewController.forumNames = viewModel.forumNames
        forumNameSelectionViewController.selectedForumName = viewModel.selectedForumName
        forumNameSelectionViewController.delegate = self
        present(forumNameSelectionViewController, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        titleView.resetDisclosureImageViewStatus()
        
        return true
    }
}

// MARK: - ForumNameSelectionDelegate

extension HomeViewController: ForumNameSelectionDelegate {
    func forumNameDidSelected(forumName: String) {
        if self.forumName == forumName {
            titleView.resetDisclosureImageViewStatus()
        } else {
            self.forumName = forumName
        }
    }
}

// MARK: - TableViewDataLoadDelegate

extension HomeViewController: DataLoadDelegate {
    func loadNewData() {
        viewModel.refreshData { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                self.tableView.reloadData()
                self.tableView.endRefreshing()
                if self.viewModel.numberOfThreads() > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.tableView.status = .normal
                } else {
                    self.tableView.status = .noResult
                }
                if !self.viewModel.canLoadMoreData {
                    self.tableView.endLoadMoreWithNoMoreData()
                } else {
                    self.tableView.resetNoMoreData()
                }
            case .failure(let error):
                if self.tableView.status == .loading {
                    self.tableView.status = .tapToLoad
                } else {
                    self.tableView.status = .normal
                }
                self.showPromptInformation(of: .failure("\(error)"))
                self.tableView.endRefreshing()
            }
        }
    }
    
    func loadMoreData() {
        viewModel.loadMoreData { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                self.tableView.reloadData()
                if !self.viewModel.canLoadMoreData {
                    self.tableView.endLoadMoreWithNoMoreData()
                } else {
                    self.tableView.endLoadMore()
                    self.tableView.resetNoMoreData()
                }
                self.tableView.status = .normal
            case .failure(let error):
                self.tableView.status = .normal
                self.showPromptInformation(of: .failure("\(error)"))
                self.tableView.endLoadMore()
            }
        }
    }
}

// MARK: - UITablViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: HomeThreadTableViewCell.reuseIdentifier, configuration: { [weak self] cell in
            guard let threadCell = cell as? HomeThreadTableViewCell else { return }
            threadCell.justForHeightCaculation = true
            threadCell.fd_enforceFrameLayout = true
            threadCell.threadModel = self?.viewModel.threadModel(at: indexPath.row)
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.readThread(at: indexPath.row)
        
        let tid = viewModel.tid(at: indexPath.row)
        let readPostVC = PostViewController.load(from: .home)
        readPostVC.postInfo = PostInfo(tid: tid)
        pushViewController(readPostVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { [weak self] action, index in
            self?.viewModel.deleteThread(at: editActionsForRowAt.row)
            self?.tableView.deleteRows(at: [editActionsForRowAt], with: .automatic)
        }
        
        let addThreadUserToUserBlock = UITableViewRowAction(style: .normal, title: "屏蔽") { [weak self] action, index in
            self?.viewModel.addThreadUserToUserBlock(at: editActionsForRowAt.row)
            self?.tableView.deleteRows(at: [editActionsForRowAt], with: .automatic)
        }
        
        return [delete, addThreadUserToUserBlock]
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfThreads()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as HomeThreadTableViewCell
        cell.justForHeightCaculation = false
        cell.threadModel = self.viewModel.threadModel(at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension HomeViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths  {
            _ = tableView.fd_heightForCell(withIdentifier: HomeThreadTableViewCell.reuseIdentifier, configuration: { [weak self] cell in
                guard let threadCell = cell as? HomeThreadTableViewCell else { return }
                threadCell.threadModel = self?.viewModel.threadModel(at: indexPath.row)
            })
        }
    }
}
