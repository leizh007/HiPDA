//
//  File.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import UITableView_FDTemplateLayoutCell
import RxSwift
import RxCocoa

fileprivate enum Constants {
    static let deleteButtonHeight = CGFloat(44.0) + CGFloat.from(pixel: 1)
}

class FavoritesAndAttentionBaseViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    @IBOutlet weak var deletButton: UIButton!
    @IBOutlet weak var deleteButtonBottomConstraint: NSLayoutConstraint!
    var viewModel: FavoritesAndAttentionBaseViewModel!
    fileprivate var isTableViewInMultipleSelectionMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinViewModel()
        skinTableView()
        deleteButtonBottomConstraint.constant = -Constants.deleteButtonHeight
        deletButton.layer.shadowOffset = CGSize(width: 0, height: -CGFloat.from(pixel: 1))
        deletButton.layer.shadowRadius = 0
        deletButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        deletButton.layer.shadowOpacity = 0.25
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(selectButtonSelected))
    }
    
    func selectButtonSelected() {
        isTableViewInMultipleSelectionMode = !isTableViewInMultipleSelectionMode
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: isTableViewInMultipleSelectionMode ? "取消" : "编辑", style: .plain, target: self, action: #selector(selectButtonSelected))
        tableView.setEditing(isTableViewInMultipleSelectionMode, animated: true)
        UIView.animate(withDuration: C.UI.animationDuration) { 
            self.deleteButtonBottomConstraint.constant = self.isTableViewInMultipleSelectionMode ? 0.0 : -Constants.deleteButtonHeight
            self.deletButton.isEnabled = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction fileprivate func deleteButtonPressed(_ sender: UIButton) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        delete(indexs: indexPaths.map { $0.row })
    }
    
    func skinViewModel() {
        fatalError("Must be overrided!")
    }
    
    fileprivate func skinTableView() {
        tableView.status = .loading
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.hasRefreshHeader = true
        tableView.hasLoadMoreFooter = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.register(FavoritesAndAttentionBaseTableViewCell.self)
        loadNewData()
    }
    
    fileprivate func delete(indexs: [Int]) {
        showPromptInformation(of: .loading("正在删除..."))
        viewModel.delete(indexs: indexs) { [weak self] result in
            self?.hidePromptInformation()
            switch result {
            case .success(_):
                self?.showPromptInformation(of: .success("删除成功"))
                self?.viewModel.delete(at: indexs)
                self?.selectButtonSelected()
                self?.tableView.deleteRows(at: indexs.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                if (self?.viewModel.hasData ?? false) {
                    self?.tableView.status = .normal
                } else {
                    self?.tableView.status = .loading
                    self?.loadNewData()
                }
            case .failure(let error):
                self?.showPromptInformation(of: .failure(error.localizedDescription))
            }
        }
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
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            
            URLDispatchManager.shared.linkActived(viewModel.jumpURL(at: indexPath.row))
        } else {
            deletButton.isEnabled = (tableView.indexPathsForSelectedRows ?? []).count > 0
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            deletButton.isEnabled = (tableView.indexPathsForSelectedRows ?? []).count > 0
        }
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
