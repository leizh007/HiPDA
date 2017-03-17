//
//  AccountManagementTableViewEditingCommand.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 账户管理tableView编辑操作
///
/// - insert: 插入(只会插在section 0处)
/// - move: 移动
/// - delete: 删除
enum AccountManagementTableViewEditingCommand {
    case insert(AccountItemType, at: IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case delete(with: IndexPath)
}
