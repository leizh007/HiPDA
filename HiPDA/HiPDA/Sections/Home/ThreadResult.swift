//
//  HiPDAThreadResult.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 获取论坛列表错误
///
/// - parseError: 解析错误
/// - unKnown: 未知错误
enum HiPDAThreadError: Error {
    case parseError(String)
    case unKnown(String)
}

// MARK: - CustomStringConvertible

extension HiPDAThreadError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .parseError(errorString):
            return errorString
        case let .unKnown(errorString):
            return errorString
        }
    }
}

typealias HiPDAThreadsResult = HiPDA.Result<[HiPDA.Thread], HiPDAThreadError>
