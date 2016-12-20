//
//  TableViewEditingCommand.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

// MARK: - Command

/// TableView编辑指令
///
/// - replace: 替换
/// - append: 添加
/// - move: 移动
/// - delete: 删除
enum TableViewEditingCommand<State: TableViewState> {
    case replace(State)
    case append(State.Section.Item, in: Int)
    case move(from: IndexPath, to: IndexPath)
    case delete(with: IndexPath)
}

// MARK: - State

/// TableView状态
protocol TableViewState: Equatable {
    associatedtype Section: AnimatableSectionModelType, Equatable
    
    var sections: [Section] { get }
    init(sections: [Section])
    func execute(_ command: TableViewEditingCommand<Self>) -> Self
}

extension TableViewState {
    /// 执行指令
    ///
    /// - Parameter command: 指令
    /// - Returns: 返回执行后的状态
    func execute(_ command: TableViewEditingCommand<Self>) -> Self {
        switch command {
        case let .replace(state):
            return state
        case let .append(item, in: section):
            var sections = self.sections
            let items = sections[section].items + item
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
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        if lhs.sections.count != rhs.sections.count {
            return false
        }
        
        return (0..<lhs.sections.count).reduce(true) {
            $0 && (lhs.sections[$1] == rhs.sections[$1])
        }
    }
}
