//
//  MyThreadsBaseTableViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class MyThreadsBaseTableViewController: BaseViewController {
    var tableView: BaseTableView!
    fileprivate var isDataLoaded = false
    var viewModel: MyThreadsBaseTableViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinViewModel()
        skinTableView()
    }
    
    func skinViewModel() {
        fatalError("Must be overrided!")
    }
    
    func skinTableView() {
        let frame = CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: C.UI.screenHeight - 64)
        tableView = BaseTableView(frame: frame, style: .grouped)
        view.addSubview(tableView)
        tableView.hasRefreshHeader = true
        tableView.hasLoadMoreFooter = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.status = .normal
    }
    
    func loadData() {
        guard !isDataLoaded else { return }
        isDataLoaded = true
        tableView.status = .loading
        loadNewData()
    }
    
    func tabBarItemDidSelectRepeatedly() {
        guard tableView.status != .noResult && tableView.status != .loading && tableView.status != .tapToLoad else { return }
        if tableView.contentOffset.y > 0 {
            tableView.setContentOffset(.zero, animated: true)
        } else {
            tableView.refreshing()
        }
    }
}

// MARK: - UITableViewDelegate

extension MyThreadsBaseTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        URLDispatchManager.shared.linkActived(viewModel.jumpURL(at: indexPath.row))
    }
}

// MARK: - UITableViewDataSource

extension MyThreadsBaseTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: "cell")
    }
}

// MARK: - DataLoadDelegate

extension MyThreadsBaseTableViewController: DataLoadDelegate {
    func loadNewData() {
        viewModel.loadFirstPage { [weak self] result in
            self?.handleDataLoadResult(result)
        }
    }
    
    func loadMoreData() {
        viewModel.loadNextPage { [weak self] result in
            self?.handleDataLoadResult(result)
        }
    }
    
    fileprivate func handleDataLoadResult(_ result: HiPDA.Result<Void, NSError>) {
        switch result {
        case .success(_):
            tableView.status = viewModel.hasData ? .normal : .noResult
        case .failure(let error):
            showPromptInformation(of: .failure(error.localizedDescription))
            tableView.status = tableView.status == .loading ? .tapToLoad : .normal
        }
        tableView.reloadData()
        tableView.endRefreshing()
        if viewModel.hasMoreData {
            tableView.endLoadMore()
            tableView.resetNoMoreData()
        } else {
            tableView.endLoadMoreWithNoMoreData()
        }
    }
}
