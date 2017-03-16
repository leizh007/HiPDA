//
//  AccountManagementViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/10.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

struct AccountManagementTableViewState {
    let sections: [AccountManagementSection]
    
    func execute(_ command: AccountManagementTableViewEditingCommand) -> AccountManagementTableViewState {
        switch command {
        case let .insert(item, at: indexPath):
            var sections = self.sections
            var section = sections[indexPath.section]
            section.items.insert(item, at: indexPath.row)
            sections[indexPath.section] = section
            return AccountManagementTableViewState(sections: sections)
        case .delete(with: let indexPath):
            var sections = self.sections
            sections[indexPath.section].items.remove(at: indexPath.row)
            return AccountManagementTableViewState(sections: sections)
        case let .move(from: sourceIndexPath, to: destinationIndexPath):
            var sections = self.sections
            var sourceItems = sections[sourceIndexPath.section].items
            var destinationItems = sections[destinationIndexPath.section].items
            
            if sourceIndexPath.section == destinationIndexPath.section {
                destinationItems.insert(destinationItems.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
                let destinationSection = AccountManagementSection(original: sections[destinationIndexPath.section], items: destinationItems)
                sections[sourceIndexPath.section] = destinationSection
                return AccountManagementTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: sourceIndexPath.row)
                destinationItems.insert(item, at: destinationIndexPath.row)
                let sourceSection = AccountManagementSection(original: sections[sourceIndexPath.section], items: sourceItems)
                let destinationSection = AccountManagementSection(original: sections[destinationIndexPath.section], items: destinationItems)
                sections[sourceIndexPath.section] = sourceSection
                sections[destinationIndexPath.section] = destinationSection
                return AccountManagementTableViewState(sections: sections)
            }
        }
    }
}

// MARK: - Equatable

extension AccountManagementTableViewState: Equatable {
    static func ==(lhs: AccountManagementTableViewState, rhs: AccountManagementTableViewState) -> Bool {
        return lhs.sections.count == rhs.sections.count &&
        (0..<lhs.sections.count).reduce(true) {
            $0 && lhs.sections[$1] == rhs.sections[$1]
        }
    }
}
