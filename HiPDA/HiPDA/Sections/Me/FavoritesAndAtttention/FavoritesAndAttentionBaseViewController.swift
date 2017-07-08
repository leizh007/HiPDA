//
//  File.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import UITableView_FDTemplateLayoutCell

class FavoritesAndAttentionBaseViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    var viewModel: FavoritesAndAttentionBaseViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinViewModel()
        skinTableView()
    }
    
    func skinViewModel() {
        fatalError("Must be overrided!")
    }
    
    fileprivate func skinTableView() {
        tableView.status = .loading
        tableView.hasRefreshHeader = true
        tableView.hasLoadMoreFooter = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.register(FavoritesAndAttentionBaseTableViewCell.self)
        loadNewData()
    }
}

// MARK: - UITableViewDelegate

extension FavoritesAndAttentionBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: FavoritesAndAttentionBaseTableViewCell.reuseIdentifier) { [weak self] cell in
            guard let searchCell = cell as? FavoritesAndAttentionBaseTableViewCell, let `self` = self else { return }
            searchCell.model = self.viewModel.model(at: indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource

extension FavoritesAndAttentionBaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as FavoritesAndAttentionBaseTableViewCell
        cell.model = viewModel.model(at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        URLDispatchManager.shared.linkActived(viewModel.jumpURL(at: indexPath.row))
    }
}

// MARK: - DataLoadDelegate

extension FavoritesAndAttentionBaseViewController: DataLoadDelegate {
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
    
    fileprivate func handleDataLoadResult(_ result: FavoritesAndAttentionResult) {
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
