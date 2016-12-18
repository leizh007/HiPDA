//
//  EditWordListSectionedTableViewState.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/14.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 编辑词组的动作
///
/// - append: 添加
/// - move: 移动
/// - delete: 删除
enum EditWordListTableViewEditingCommand {
    case replace(EditWordListTableViewState)
    case append(String, in: Int)
    case move(from: IndexPath, to: IndexPath)
    case delete(with: IndexPath)
}

/// 编辑词组的TableView的状态
struct EditWordListTableViewState {
    let sections: [EditWordListSection]
    
    /// 执行command
    ///
    /// - Parameter command: 指令
    /// - Returns: 返回执行后的状态
    func execute(_ command: EditWordListTableViewEditingCommand) -> EditWordListTableViewState {
        switch command {
        case let .replace(state):
            return state
        case let .append(item, in: section):
            var sections = self.sections
            let items = sections[section].items + item
            sections[section] = EditWordListSection(original: sections[section], items: items)
            return EditWordListTableViewState(sections: sections)
        case let .delete(with: indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = EditWordListSection(original: sections[indexPath.section], items: items)
            return EditWordListTableViewState(sections: sections)
        case let .move(from: sourceIndexPath, to: destinationIndexPath):
            var sections = self.sections
            var sourceItems = sections[sourceIndexPath.section].items
            var destinationItems = sections[destinationIndexPath.section].items
            
            if sourceIndexPath.section == destinationIndexPath.section {
                destinationItems.insert(destinationItems.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
                let destinationSection = EditWordListSection(original: sections[destinationIndexPath.section], items: destinationItems)
                sections[sourceIndexPath.section] = destinationSection
                return EditWordListTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: sourceIndexPath.row)
                destinationItems.insert(item, at: destinationIndexPath.row)
                let sourceSection = EditWordListSection(original: sections[sourceIndexPath.section], items: sourceItems)
                let destinationSection = EditWordListSection(original: sections[destinationIndexPath.section], items: destinationItems)
                sections[sourceIndexPath.section] = sourceSection
                sections[destinationIndexPath.section] = destinationSection
                return EditWordListTableViewState(sections: sections)
            }
        }
    }
}

// MARK: - Equable

extension EditWordListTableViewState: Equatable {
    static func ==(lhs: EditWordListTableViewState, rhs: EditWordListTableViewState) -> Bool {
        if lhs.sections.count != rhs.sections.count {
            return false
        }
        
        return (0..<lhs.sections.count).reduce(true) {
            $0 && (lhs.sections[$1] == rhs.sections[$1])
        }
    }
}

// MARK: - Convenience Function

/// 数组添加元素
///
/// - Parameters:
///   - lhs: 数组
///   - rhs: 元素
/// - Returns: 返回添加完的数组的拷贝
fileprivate func +<T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
