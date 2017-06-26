//
//  SearchUserThreadsViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class SearchUserThreadsViewController: UIViewController {
    var user: User!
    fileprivate var viewModel: SearchUserThreadsViewModel!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(user.name)发表的帖子"
        viewModel = SearchUserThreadsViewModel(user: user)
        skinTableView(tableView)
        loadNewData()
    }
    
    fileprivate func skinTableView(_ tableView: BaseTableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.status = .loading
        tableView.hasRefreshHeader = true
        tableView.hasLoadMoreFooter = true
    }
}

// MARK: - UITableViewDelegate

extension SearchUserThreadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: - UITableViewDataSource

extension SearchUserThreadsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfModels()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: "cell")
    }
}

// MARK: - DataLoadDelegate

extension SearchUserThreadsViewController: DataLoadDelegate {
    func loadNewData() {
        viewModel.loadNewData { [weak self] result in
            self?.handleDataLoadResult(result)
        }
    }
    
    func loadMoreData() {
        viewModel.loadMoreData { [weak self] result in
            self?.handleDataLoadResult(result)
        }
    }
    
    private func handleDataLoadResult(_ result: SearchUserThreadsResult) {
        switch result {
        case .success(_):
            tableView.status = viewModel.hasData ? .normal : .noResult
        case .failure(let error):
            showPromptInformation(of: .failure(error.localizedDescription))
            tableView.status = tableView.status == .loading ? .tapToLoad : .normal
        }
        tableView.endRefreshing()
        if viewModel.hasMoreData {
            tableView.endLoadMore()
            tableView.resetNoMoreData()
        } else {
            tableView.endLoadMoreWithNoMoreData()
        }
        tableView.reloadData()
    }
}

// MARK: - StoryboardLoadable

extension SearchUserThreadsViewController: StoryboardLoadable { }
