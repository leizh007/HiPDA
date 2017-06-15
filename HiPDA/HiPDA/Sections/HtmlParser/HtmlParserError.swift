//
//  RegexError.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// Html解析错误
///
/// - regexCreateFailed: 无法创建正则表达式
/// - cannotGetUid:      无法获取uid
/// - cannotGetUsername: 无法获取username
/// - unKnown:           未知错误
enum HtmlParserError: Error {
    case regexCreateFailed(String)
    case cannotGetUid
    case cannotGetUsername
    case unKnown(String)
}

extension HtmlParserError: CustomStringConvertible {
    var description: String {
        switch self {
        case .regexCreateFailed(let regex):
            return "正则表达式：\(regex)，创建失败！"
        case .cannotGetUid:
            return "无法获取uid"
        case .cannotGetUsername:
            return "无法获取用户名"
        case .unKnown(let value):
            return value
        }
    }
}

extension HtmlParserError: LocalizedError {
    var errorDescription: String? {
        return description
    }
}
