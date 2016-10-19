//
//  RegexError.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 解析错误
enum HtmlParserError: Error {
    case regexCreateFailed(String)
    case cannotGetUid
    case unKnown(String)
}

extension HtmlParserError: CustomStringConvertible {
    var description: String {
        switch self {
        case .regexCreateFailed(let regex):
            return "正则表达式：\(regex)，创建失败！"
        case .cannotGetUid:
            return "无法获取uid"
        case .unKnown(let value):
            return value
        }
    }
}
