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
    let header: String
    var attributes: [UserRemark]
}

// MARK: - AnimatableSectionModelType

extension UserRemarkSection: AnimatableSection {
    typealias Item = UserRemark
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    var items: [UserRemark] {
        return attributes
    }
    
    init(original: UserRemarkSection, items: [Item]) {
        self = original
        self.attributes = items
    }
}

// MARK: - CustomStringConvertible

extension UserRemarkSection: CustomStringConvertible {
    var description: String {
        return "EditWordListSection(attributes:\(attributes))"
    }
}
