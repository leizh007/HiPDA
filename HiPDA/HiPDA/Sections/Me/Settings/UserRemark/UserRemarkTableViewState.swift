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
    
    func execute(_ command: TableViewEditingCommand<UserRemarkTableViewState>) -> UserRemarkTableViewState {
        typealias `Self` = UserRemarkTableViewState
        if case let .append(item, in: section) = command {
            var sections = self.sections
            var items = sections[section].items
            if let index = items.index(where: { $0.userName == item.userName }) {
                items[index] = item
            } else {
                items = items + item
            }
            sections[section] = Section(original: sections[section], items: items)
            return Self(sections: sections)
        } else {
            return _defaultImplementOfExecute(command)
        }
    }
}
