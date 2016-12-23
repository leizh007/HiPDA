//
//  UserRemark.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// 用户备注
struct UserRemark {
    /// 用户名
    let userName: String
    
    /// 备注名
    let remarkName: String
}

// MARK: - IdentifiableType

extension UserRemark: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return "\(self)"
    }
}

// MARK: - Equatable

extension UserRemark: Equatable {
    static func ==(lhs: UserRemark, rhs: UserRemark) -> Bool {
        return lhs.userName == rhs.userName && lhs.remarkName == rhs.remarkName
    }
}

// MARK: - CustomStringConvertible

extension UserRemark: CustomStringConvertible {
    var description: String {
        return "UserRemark(userName: \(userName), remarkName: \(remarkName))"
    }
}
