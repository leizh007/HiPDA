//
//  ForumNameModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// 版块名称的模型
struct ForumNameModel {
    /// 版块名称
    let forumName: String
    
    /// 版块的描述信息
    let forumDescription: String?
    
    /// 等级
    ///
    /// - first: 一级
    /// - secondary: 二级
    /// - secondaryLast: 二级末尾
    enum Level {
        case first
        case secondary
        case secondaryLast
    }
    
    /// 所属级别
    let level: Level
    
    /// 是否被选中
    var isChoosed: Bool
}

// MARK: - IdentifiableType

extension ForumNameModel: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return "\(self)"
    }
}

// MARK: - Equatable

extension ForumNameModel: Equatable {
    static func ==(lhs: ForumNameModel, rhs: ForumNameModel) -> Bool {
        return lhs.forumName == rhs.forumName &&
            lhs.level == rhs.level &&
            lhs.isChoosed == rhs.isChoosed
    }
}

// MARK: - CustomStringConvertible

extension ForumNameModel: CustomStringConvertible {
    var description: String {
        return "ForumNameModel(forumName: \(forumName), level: \(level), isChoosed: \(isChoosed))"
    }
}
