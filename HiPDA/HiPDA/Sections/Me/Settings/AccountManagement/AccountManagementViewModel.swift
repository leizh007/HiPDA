//
//  AccountManagementViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 账户+添加账户section
fileprivate let kAccountSection = 0

/// 退出登录账户section
fileprivate let kLogoutSection = 1

/// 账户管理的viewModel
struct AccountManagementViewModel {
    fileprivate let settings = Settings.shared
    
    /// view是否处在编辑状态
    fileprivate var isEditing = false
    
    /// 账户列表
    fileprivate var accountList: [Account] {
        get {
            return settings.accountList
        }
        
        set {
            settings.accountList = newValue
        }
    }
    
    /// 当前活跃账户
    fileprivate var activeAccount: Account? {
        get {
            return settings.activeAccount
        }
        
        set {
            settings.activeAccount = newValue
        }
    }
    
    /// 当前登录账户的下标
    var activeAccountIndex: Int {
        guard let activeAccount = activeAccount else {
            return -1
        }
        return  accountList.index(where: { account -> Bool in
            return account == activeAccount
        }) ?? -1
    }
    
    /// section的数目
    var numberOfSections: Int {
        return isEditing ? 1 : 2
    }
    
    func account(at index: Int) -> Account? {
        return accountList.safe[index]
    }
    
    /// 项目个数
    ///
    /// - Parameter section: section
    /// - Returns: 指定section下item的个数
    func numberOfItems(in section: Int) -> Int {
        return isEditing ? accountList.count :
            (section == kAccountSection ? accountList.count + 1 : 1)
    }
    
    /// 指定indexPath下的item
    ///
    /// - Parameter indexPath: indexPath
    /// - Returns: indexPath对应的item
    func item(at indexPath: IndexPath) -> AccountManagementItemtype {
        let transform: (Account) -> AccountCellModel = { account in
            return AccountCellModel(name: account.name, uid: "UID: \(account.uid)", avatarImageURL: account.avatarImageURL, accessoryType: account == self.activeAccount ? .checkmark : .none)
        }
        switch indexPath.section {
        case kAccountSection:
            guard indexPath.row < accountList.count else {
                return .addAccount
            }
            return .account(transform(accountList[indexPath.row]))
        case kLogoutSection:
            return .logout
        default:
            fatalError("UnRecognized IndexPath!")
        }
    }
    
    /// 执行操作
    ///
    /// - Parameter command: 操作
    mutating func execute(_ command: AccountManagementCommand) {
        switch command {
        case let  .append(accoun: account):
            settings.add(account: account)
            activeAccount = account
        case let .move(from: sourceIndex, to: destinationIndex):
            accountList.insert(accountList.remove(at: sourceIndex), at: destinationIndex)
        case let .delete(at: index):
            if let account = settings.lastLoggedInAccount, account == accountList[index] {
                settings.lastLoggedInAccount = nil
            }
            accountList.remove(at: index)
        case let .click(at: index):
            activeAccount = accountList[index]
        case let .changeStatus(isEditing: isEditing):
            self.isEditing = isEditing
        }
    }
}
