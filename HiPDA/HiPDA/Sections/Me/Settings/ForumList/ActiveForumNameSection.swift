//
//  ActiveForumNameSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// 编辑版块列表的TableView的section模型
struct ActiveForumNameSection {
    var forumNames: [String]
}

// MARK: - AnimatableSectionModelType

extension ActiveForumNameSection: AnimatableSection {
    typealias Item = String
    typealias Identity = String
    
    var identity: String {
        return "\(forumNames)"
    }
    
    var items: [String] {
        return forumNames
    }
    
    init(original: ActiveForumNameSection, items: [Item]) {
        self = original
        self.forumNames = items
    }
}

// MARK: - CustomStringConvertible

extension ActiveForumNameSection: CustomStringConvertible {
    var description: String {
        return "EditWordListSection(words:\(forumNames))"
    }
}
