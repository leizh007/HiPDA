//
//  AccountItemType.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

enum AccountItemType {
    case account(AccountCellModel)
    case addAccount
    case logout
}

// MARK: - IdentifiableType

extension AccountItemType: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return String(describing: self)
    }
}

// MARK: - Equatable

extension AccountItemType: Equatable {
    static func ==(lhs: AccountItemType, rhs: AccountItemType) -> Bool {
        switch (lhs, rhs) {
        case let (.account(modelLhs), .account(modelRhs)):
            return modelLhs == modelRhs
        case (.addAccount, .addAccount):
            return true
        case (.logout, .logout):
            return true
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension AccountItemType: CustomStringConvertible {
    var description: String {
        switch self {
        case let .account(model):
            return "AccountItemType: Account: \(model)"
        case .addAccount:
            return "AccountItemType: AddAccount"
        case .logout:
            return "AccountItemType: Logout"
        }
    }
}
