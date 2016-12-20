//
//  UserRemarkTableViewState.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

// MARK: - Command

typealias UserRemarkTableViewEditingCommand = TableViewEditingCommand<UserRemarkTableViewState>

// MARK: - State

/// 用户备注tableView的状态
struct UserRemarkTableViewState {
    var sections: [UserRemarkSection]
}

// MARK: - TableViewState

extension UserRemarkTableViewState: TableViewState {
    typealias Section = UserRemarkSection
}
