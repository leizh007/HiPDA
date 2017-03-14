//
//  AccountManagementTableViewEditingCommand.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

enum AccountManagementTableViewEditingCommand {
    case replace(AccountManagementTableViewState)
    case insert(AccountItemType, at: IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case delete(with: IndexPath)
    case click(with: IndexPath)
}
