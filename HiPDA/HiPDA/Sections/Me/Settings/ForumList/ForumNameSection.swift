//
//  ForumNameSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// 用户备注的section模型
struct ForumNameSection {
    var forumList: [ForumNameModel]
}

// MARK: - AnimatableSectionModelType

extension ForumNameSection: AnimatableSection {
    typealias Item = ForumNameModel
    typealias Identity = String
    
    var identity: String {
        return "\(forumList)"
    }
    
    var items: [ForumNameModel] {
        return forumList
    }
    
    init(original: ForumNameSection, items: [Item]) {
        self = original
        self.forumList = items
    }
}

// MARK: - CustomStringConvertible

extension ForumNameSection: CustomStringConvertible {
    var description: String {
        return "ForumNameSection(forumList:\(forumList))"
    }
}
