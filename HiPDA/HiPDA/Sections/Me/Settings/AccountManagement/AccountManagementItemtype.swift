//
//  AccountManagementItemtype.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 账户管理item类型
///
/// - account: 账户
/// - addAccount: 添加账户
/// - logout: 退出账户
enum AccountManagementItemtype {
    case account(AccountCellModel)
    case addAccount
    case logout
}
