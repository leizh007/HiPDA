//
//  EditWordListSectionedTableViewState.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/14.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

// MARK: - Command

typealias EditWordListTableViewEditingCommand = TableViewEditingCommand<EditWordListTableViewState>

// MARK: - State

/// 编辑词组的TableView的状态
struct EditWordListTableViewState {
    var sections: [EditWordListSection]
}

// MARK: - TableViewState

extension EditWordListTableViewState: TableViewState {
    typealias Section = EditWordListSection
}
