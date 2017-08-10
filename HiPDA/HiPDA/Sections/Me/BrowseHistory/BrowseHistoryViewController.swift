//
//  BrowseHistoryViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import UITableView_FDTemplateLayoutCell

class BrowseHistoryViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    fileprivate let viewModel = BrowseHistoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "最近浏览"
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.loadData { [weak self] _ in
            guard let `self` = self else { return }
            self.tableView.reloadData()
            self.tableView.status = self.viewModel.hasData ? .normal : .noResult
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: .plain, target: self, action: #selector(clear))
    }
    
    func clear() {
        viewModel.clear()
        tableView.reloadData()
        tableView.status = .noResult
    }
}

// MARK: - UITableViewDelegate

extension BrowseHistoryViewController: UITableViewDelegate {
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
            threadCell.threadModel = self?.viewModel.model(at: indexPath.row)
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tid = viewModel.tid(at: indexPath.row)
        let readPostVC = PostViewController.load(from: .home)
        readPostVC.postInfo = PostInfo(tid: tid)
        pushViewController(readPostVC, animated: true)
        viewModel.read(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { [unowned self] action, index in
            self.viewModel.delete(at: editActionsForRowAt.row)
            self.tableView.deleteRows(at: [editActionsForRowAt], with: .automatic)
            self.tableView.status = self.viewModel.hasData ? .normal : .noResult
        }
        
        return [delete]
    }
}

// MARK: - UITableViewDelegate

extension BrowseHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfModels()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as HomeThreadTableViewCell
        cell.justForHeightCaculation = false
        cell.threadModel = viewModel.model(at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
