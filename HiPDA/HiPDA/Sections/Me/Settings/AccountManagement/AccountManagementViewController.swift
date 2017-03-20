//
//  AccountManagementViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

/// 账户管理
class AccountManagementViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    /// viewModel
    var viewModel = AccountManagementViewModel()
    
    /// 编辑按钮
    fileprivate var editBarButtonItem: UIBarButtonItem!
    
    /// 完成按钮
    fileprivate var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        editBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editButtonPressed(sender:)))
        doneBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(editButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = editBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func editButtonPressed(sender: UIBarButtonItem) {
        struct StaticVars {
            static var isEditing = false
        }
        StaticVars.isEditing = !StaticVars.isEditing
        navigationItem.rightBarButtonItem = StaticVars.isEditing ? doneBarButtonItem : editBarButtonItem
        viewModel.execute(.changeStatus(isEditing: StaticVars.isEditing))
        tableView.isEditing = StaticVars.isEditing
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension AccountManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if case .logout = viewModel.item(at: indexPath) {
            return 44.0
        } else {
            return 56.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.item(at: indexPath) {
        case .account(_):
            // FIXME: - Change account
            tableView.cellForRow(at: IndexPath(row: viewModel.activeAccountIndex, section: 0))?.accessoryType = .none
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            viewModel.execute(.click(at: indexPath.row))
        case .addAccount:
            let loginVC = LoginViewController.load(from: .login)
            loginVC.cancelable = true
            loginVC.loggedInCompletion = { account in
                self.navigationController?.dismiss(animated: true, completion: nil)
                self.viewModel.execute(.append(accoun: account))
                self.tableView.reloadData()
                EventBus.shared.dispatch(ChangeAccountAction(account: .success(account)))
            }
            loginVC.transitioningDelegate = self
            navigationController?.present(loginVC, animated: true, completion: nil)
        case .logout:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension AccountManagementViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if case .account(_) = viewModel.item(at: indexPath) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if case .account(_) = viewModel.item(at: indexPath) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        switch item {
        case .logout:
            return tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
        case .addAccount:
            return tableView.dequeueReusableCell(withIdentifier: "AddAccount", for: indexPath)
        case let .account(model):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccoutTableViewCell", for: indexPath)
            guard let accountCell = cell as? AccoutTableViewCell else {
                return cell
            }
            accountCell.cellModel = model
            return cell
        }
    }
}
