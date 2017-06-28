//
//  MessageTableViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class MessageTableViewController: BaseViewController {
    var tableView: BaseTableView!
    var viewModel: MessageTableViewModel!
    var isVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinTableView()
        skinViewModel()
        loadNewData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    func skinTableView() {
        tableView = BaseTableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.status = .loading
        tableView.hasRefreshHeader = true
        tableView.hasLoadMoreFooter = true
        view.addSubview(tableView)
    }
    
    func skinViewModel() {
        fatalError("Must override!")
    }
    
    func accountChanged() {
        viewModel.accountChanged()
        handleDataLoadResult(.success(()))
    }
    
    func viewDidBecomeVisible() {
        isVisible = true
    }
    
    func viewDidBecomeInvisible() {
        isVisible = false
    }
    
    func cancelDataFetching() {
        viewModel.cancelDataFetching()
    }
}

// MARK: - UITableViewDelegate

extension MessageTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MessageTableViewController: UITableViewDataSource {
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

extension MessageTableViewController: DataLoadDelegate {
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
    
    fileprivate func handleDataLoadResult(_ result: MessageListResult) {
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
