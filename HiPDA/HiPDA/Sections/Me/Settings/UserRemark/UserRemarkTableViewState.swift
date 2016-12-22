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
        switch command {
        case let .replace(state):
            return state
        case let .append(item, in: section):
            var sections = self.sections
            var items = sections[section].items
            if let index = items.index(where: { $0.userName == item.userName }) {
                items[index] = item
            } else {
                items = items + item
            }
            sections[section] = Section(original: sections[section], items: items)
            return Self(sections: sections)
        case let .delete(with: indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = Section(original: sections[indexPath.section], items: items)
            return Self(sections: sections)
        case let .move(from: sourceIndexPath, to: destinationIndexPath):
            var sections = self.sections
            var sourceItems = sections[sourceIndexPath.section].items
            var destinationItems = sections[destinationIndexPath.section].items
            
            if sourceIndexPath.section == destinationIndexPath.section {
                destinationItems.insert(destinationItems.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
                let destinationSection = Section(original: sections[destinationIndexPath.section], items: destinationItems)
                sections[sourceIndexPath.section] = destinationSection
                return Self(sections: sections)
            } else {
                let item = sourceItems.remove(at: sourceIndexPath.row)
                destinationItems.insert(item, at: destinationIndexPath.row)
                let sourceSection = Section(original: sections[sourceIndexPath.section], items: sourceItems)
                let destinationSection = Section(original: sections[destinationIndexPath.section], items: destinationItems)
                sections[sourceIndexPath.section] = sourceSection
                sections[destinationIndexPath.section] = destinationSection
                return Self(sections: sections)
            }
        }
    }
}
