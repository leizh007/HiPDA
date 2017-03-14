//
//  AccountManagementSection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

struct AccountManagementSection {
    let header: String
    var items: [AccountItemType]
}

// MARK: - AnimatableSectionModelType

extension AccountManagementSection: AnimatableSectionModelType {
    typealias Item = AccountItemType
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    init(original: AccountManagementSection, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: - CustomStringConvertible

extension AccountManagementSection: CustomStringConvertible {
    var description: String {
        return "AccountManagementSection(items: \(items))"
    }
}

// MARK: - Equatable

extension AccountManagementSection: Equatable {
    static func ==(lhs: AccountManagementSection, rhs: AccountManagementSection) -> Bool {
        return lhs.items.count == rhs.items.count &&
        lhs.header == rhs.header &&
        (0..<lhs.items.count).reduce(true) {
            $0 && lhs.items[$1] == rhs.items[$1]
        }
    }
}
