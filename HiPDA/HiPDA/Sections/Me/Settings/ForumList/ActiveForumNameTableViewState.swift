//
//  ActiveForumNameSectionTableViewState.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

// MARK: - Command

typealias ActiveForumNameTableViewEditingCommand = TableViewEditingCommand<ActiveForumNameTableViewState>

// MARK: - State

/// 编辑词组的TableView的状态
struct ActiveForumNameTableViewState {
    var sections: [ActiveForumNameSection]
    
    init(sections: [ActiveForumNameSection]) {
        self.sections = sections
    }
    
    init(forumNames: [String]) {
        sections = [ActiveForumNameSection(forumNames: forumNames)]
    }
}

// MARK: - TableViewState

extension ActiveForumNameTableViewState: TableViewState {
    typealias Section = ActiveForumNameSection
}
