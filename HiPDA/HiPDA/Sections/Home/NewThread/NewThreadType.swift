//
//  NewThreadType.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

enum NewThreadType {
    case new
    case reply
    case quote
}

// MARK: - CustomStringConvertible

extension NewThreadType: CustomStringConvertible {
    var description: String {
        switch self {
        case .new:
            return "发表新帖"
        case .reply:
            return "回复"
        case .quote:
            return "引用"
        }
    }
}
