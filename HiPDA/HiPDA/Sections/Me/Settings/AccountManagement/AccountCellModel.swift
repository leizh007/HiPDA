//
//  AccountCellModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct AccountCellModel {
    let name: String
    let uid: String
    let avatarImageURL: URL
    let accessoryType: UITableViewCellAccessoryType
}

// MARK: - CustomStringConvertible

extension AccountCellModel: CustomStringConvertible {
    var description: String {
        return "AccountCellModel(name: \(name), uid: \(uid), avatarImageURL: \(avatarImageURL), accessoryType: \(accessoryType))"
    }
}

// MARK: - Equatable

extension AccountCellModel: Equatable {
    static func ==(lhs: AccountCellModel, rhs: AccountCellModel) -> Bool {
        return lhs.name == rhs.name &&
        lhs.uid == rhs.uid &&
        lhs.avatarImageURL == rhs.avatarImageURL &&
        lhs.accessoryType == rhs.accessoryType
    }
}

// MARK: - Lens

extension AccountCellModel {
    enum lens {
        static let accessoryType = Lens<AccountCellModel, UITableViewCellAccessoryType>(get: { $0.accessoryType }, set: { AccountCellModel(name: $1.name, uid: $1.uid, avatarImageURL: $1.avatarImageURL, accessoryType: $0) })
    }
}
