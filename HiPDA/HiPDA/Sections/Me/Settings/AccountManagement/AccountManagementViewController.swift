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

typealias AccountManagementCompletion = (AccountInfos) -> ()

/// 账户管理
class AccountManagementViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    /// 账户信息
    var accountInfos: AccountInfos! {
        didSet {
            activeAccount = accountInfos.activeAccount
        }
    }
    
    /// 当前账户
    var activeAccount: Account?
    
    /// 设置完回调
    var completion: AccountManagementCompletion?
    
    /// 设置完信号
    fileprivate let willDismiss = Variable(false)
    
    /// 数据源
    fileprivate let dataSource = RxTableViewSectionedAnimatedDataSource<AccountManagementSection>()
    
    /// 编辑
    fileprivate let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
    
    /// 完成
    fileprivate let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editBarButtonItem
        configureTableView()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        guard parent == nil else { return }
        willDismiss.value = true
    }
}

// MARK: - Configurations

extension AccountManagementViewController {
    /// 设置tableView的属性
    fileprivate func configureTableView() {
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)
        
        skinTableViewDataSource(dataSource)
        
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            if case .account(let account) = self.dataSource[indexPath] {
                self.activeAccount = account
            }
        }).addDisposableTo(disposeBag)
        
        let initialState = initialTableviewState()
        
        let deleteCommand = PublishSubject<AccountManagementTableViewEditingCommand>()
        configureDeleteCommand(deleteCommand)
        let insertCommand = PublishSubject<AccountManagementTableViewEditingCommand>()
        let moveCommand = tableView.rx.itemMoved
            .map(AccountManagementTableViewEditingCommand.move)
        
        let stateFilter = Variable(false)
        configureTableViewFilter(stateFilter)
        
        let rawData = Observable.of(deleteCommand, insertCommand, moveCommand)
            .merge()
            .scan(initialState) {
                return $0.execute($1)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }.shareReplay(1)
        let data = Observable.combineLatest(rawData, stateFilter.asObservable()) { sections, state -> [AccountManagementSection] in
            if state {
                var items = sections[0].items
                items.removeLast()
                return [AccountManagementSection(header: "0", items: items)]
            } else {
                return sections
            }
        }.shareReplay(1)
        
        data.bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        willDismiss.asObservable().filter { $0 }
            .withLatestFrom(rawData).map { sections -> [Account] in
                return sections[0].items.flatMap { item in
                    if case .account(let account) = item  {
                        return account
                    } else {
                        return nil
                    }
                }
            }.map { [unowned self] accounts in
                return AccountInfos(accounts: accounts, activeAccount: self.activeAccount)
            }.subscribe(onNext: { [unowned self] accountInfos in
                self.completion?(accountInfos)
            }).addDisposableTo(disposeBag)
    }
    
    /// 设置tableView的数据源
    ///
    /// - Parameter dataSource: 数据源
    fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedAnimatedDataSource<AccountManagementSection>) {
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left)
        dataSource.configureCell = { [unowned self] (_, tableView, indexPath, item) in
            switch item {
            case .account(let account):
                let cell = tableView.dequeueReusableCell(withIdentifier: "AccoutTableViewCell", for: indexPath) as! AccoutTableViewCell
                cell.cellModel = AccountCellModel(name: account.name, uid: "\(account.uid)", avatarImageURL: account.avatarImageURL, accessoryType: account == self.activeAccount ? .checkmark : .none)
                return cell
            case .addAccount:
                return tableView.dequeueReusableCell(withIdentifier: "AddAccount", for: indexPath)
            case .logout:
                return tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath)
            }
        }
        
        dataSource.canEditRowAtIndexPath = { (dataSource, indexPath) in
            if case .account(_) = dataSource[indexPath] {
                return true
            } else {
                return false
            }
        }
        dataSource.canMoveRowAtIndexPath = dataSource.canEditRowAtIndexPath
    }
}

// MARK: - Private Methods 

extension AccountManagementViewController {
    /// 获取tableView的初始状态
    func initialTableviewState() -> AccountManagementTableViewState {
        let accounts = accountInfos.accounts
            .map {
                AccountItemType.account($0)
            }
        let sections = [
            AccountManagementSection(header: "0", items: accounts + .addAccount),
            AccountManagementSection(header: "1", items: [.logout])
        ]
        
        return AccountManagementTableViewState(sections: sections)
    }
    
    /// 配置删除指令
    ///
    /// - Parameter deleteCommand: 删除指令
    func configureDeleteCommand(_ deleteCommand: PublishSubject<AccountManagementTableViewEditingCommand>) {
        tableView.rx.itemDeleted.subscribe(onNext: { [unowned self] indexPath in
            if case .account(let account) = self.dataSource[indexPath], account == self.activeAccount {
                let alert = UIAlertController(title: "删除账户", message: "确认删除当前登陆账户？删除后将会退出登录！", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let confirmAction = UIAlertAction(title: "确定", style: .default, handler: { _ in
                    deleteCommand.onNext(.delete(with: indexPath))
                })
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                deleteCommand.onNext(.delete(with: indexPath))
            }
        }).addDisposableTo(disposeBag)
    }
    
    /// 设置tableView的编辑状态
    ///
    /// - Parameter editingFilter: 编辑状态
    func configureTableViewFilter(_ editingFilter: Variable<Bool>) {
        editBarButtonItem.rx.tap
            .map {
                return true
            }
            .bindTo(editingFilter)
            .addDisposableTo(disposeBag)
        doneBarButtonItem.rx.tap
            .map {
                return false
            }
            .bindTo(editingFilter)
            .addDisposableTo(disposeBag)
        editingFilter.asObservable()
            .do(onNext: { [unowned self] isEditing in
                self.navigationItem.rightBarButtonItem = isEditing ? self.doneBarButtonItem : self.editBarButtonItem
            })
            .bindTo(tableView.rx.isEditing)
            .addDisposableTo(disposeBag)
        
    }
}

// MARK: - UITableViewDelegate

extension AccountManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath] {
        case .account(_):
            fallthrough
        case .addAccount:
            return 56.0
        case .logout:
            return 44.0
        }
    }
}
