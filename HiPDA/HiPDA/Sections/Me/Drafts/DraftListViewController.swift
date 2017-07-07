//
//  DraftListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import UITableView_FDTemplateLayoutCell

class DraftListViewController: BaseViewController {
    fileprivate let viewModel = DraftListViewModel()
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "草稿箱"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        tableView.status = viewModel.hasData ? .normal : .noResult
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

// MARK: - UITableViewDelegateu xi

extension DraftListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newThreadVC = NewThreadViewController.load(from: .home)
        newThreadVC.draft = viewModel.model(at: indexPath.row)
        newThreadVC.draftEditCompleted = { [unowned self] draft in
            self.viewModel.updateDraft(draft, at: indexPath.row)
            self.tableView.reloadData()
        }
        newThreadVC.draftSendSuccessCompletion = { [unowned self] _ in
            self.viewModel.delete(at: indexPath.row)
            self.tableView.reloadData()
            self.tableView.status = self.viewModel.hasData ? .normal : .noResult
        }
        let nav = UINavigationController(rootViewController: newThreadVC)
        nav.transitioningDelegate = self
        present(nav, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: DraftTableViewCell.reuseIdentifier) { [unowned self] cell in
            guard let draftCell = cell as? DraftTableViewCell else { return }
            draftCell.model = self.viewModel.model(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { [unowned self] action, index in
            self.viewModel.delete(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.status = self.viewModel.hasData ? .normal : .noResult
        }
        
        return [delete]
    }
}

// MARK: - UITableViewDataSource

extension DraftListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfModels()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as DraftTableViewCell
        cell.model = viewModel.model(at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
