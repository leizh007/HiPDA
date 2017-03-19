//
//  AccountManagementCommand.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 账户管理操作
///
/// - append: 添加
/// - delete: 删除
/// - move: 移动
/// - click: 点击（切换账户）
/// - changeStatus: 切换编辑状态
enum AccountManagementCommand {
    case append(accoun: Account)
    case delete(in: Int)
    case move(from: Int, to: Int)
    case click(at: Int)
    case changeStatus(isEditing: Bool)
}
