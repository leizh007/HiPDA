//
//  UserRemarkSection.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// 用户备注的section模型
struct UserRemarkSection {
    var attributes: [UserRemark]
}

// MARK: - AnimatableSectionModelType

extension UserRemarkSection: AnimatableSectionModelType {
    typealias Item = UserRemark
    typealias Identity = String
    
    var identity: String {
        return "\(attributes)"
    }
    
    var items: [UserRemark] {
        return attributes
    }
    
    init(original: UserRemarkSection, items: [Item]) {
        self = original
        self.attributes = items
    }
}

// MARK: - Equatable

extension UserRemarkSection: Equatable {
    static func ==(lhs: UserRemarkSection, rhs: UserRemarkSection) -> Bool {
        if lhs.items.count != rhs.items.count {
            return false
        }
        
        return (0..<lhs.items.count).reduce(true) {
            $0 && (lhs.items[$1] == rhs.items[$1])
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension UserRemarkSection: CustomStringConvertible {
    var description: String {
        return "EditWordListSection(attributes:\(attributes))"
    }
}
