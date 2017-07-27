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
        tabBarController?.tabBar.isHidden = true
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
            if let account = viewModel.account(at: indexPath.row) {
                showPromptInformation(of: .loading("正在切换账户..."))
                LoginManager.login(with: account).subscribe(onNext: { [unowned self] loginResult in
                    self.hidePromptInformation()
                    switch loginResult {
                    case .success(_):
                        self.tableView.cellForRow(at: IndexPath(row: self.viewModel.activeAccountIndex, section: 0))?.accessoryType = .none
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        self.viewModel.execute(.click(at: indexPath.row))
                        EventBus.shared.dispatch(ChangeAccountAction(account: .success(account)))
                        self.showPromptInformation(of: .success("账户切换成功!"))
                    case .failure(let error):
                        guard let account = Settings.shared.activeAccount else { return }
                        CookieManager.shared.set(cookies: CookieManager.shared.cookies(for: account), for: account)
                        self.showPromptInformation(of: .failure("账户切换失败: \(error)"))
                    }
                }).disposed(by: disposeBag)
            }
        case .addAccount:
            let loginVC = LoginViewController.load(from: .login)
            loginVC.cancelable = true
            loginVC.loggedInCompletion = { account in
                self.navigationController?.dismiss(animated: true, completion: nil)
                self.viewModel.execute(.append(accoun: account))
                self.tableView.reloadData()
                EventBus.shared.dispatch(ChangeAccountAction(account: .success(account)))
            }
            loginVC.cancelCompletion = { _ in
                guard let account = Settings.shared.activeAccount else { return }
                CookieManager.shared.set(cookies: CookieManager.shared.cookies(for: account), for: account)
            }
            loginVC.transitioningDelegate = self
            navigationController?.present(loginVC, animated: true, completion: nil)
        case .logout:
            EventBus.shared.dispatch(ChangeAccountAction(account: nil))
            Settings.shared.shouldAutoLogin = false
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
        viewModel.execute(.move(from: sourceIndexPath.row, to: destinationIndexPath.row))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = viewModel.item(at: indexPath)
            guard case let .account(model) = item else { return }
            if model.accessoryType == .checkmark {
                let alert = UIAlertController(title: "删除账户", message: "删除当前登录的账户将会退出登录", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let confirmAction = UIAlertAction(title: "确定", style: .default, handler: { [unowned self] _ in
                    self.viewModel.execute(.delete(at: indexPath.row))
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    EventBus.shared.dispatch(ChangeAccountAction(account: nil))
                })
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                present(alert, animated: true, completion: nil)
            } else {
                viewModel.execute(.delete(at: indexPath.row))
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
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
