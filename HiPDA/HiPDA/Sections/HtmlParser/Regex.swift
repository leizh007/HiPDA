//
//  Regex.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 正则解析
struct Regex {
    
    /// 寻找第一个匹配
    ///
    /// - parameter content: 待匹配的内容
    /// - parameter pattern: 正则表达式字符串
    ///
    /// - throws: 异常类型：RegexError
    ///
    /// - returns: 返回第一个匹配正确的字符串数组
    static func firstMatch(in content: String, of pattern: String) throws -> [String] {
        do {
            let content = content as NSString
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            guard let result = regex.firstMatch(in: content as String, range: NSRange(location: 0, length: content.length)) else {
                return []
            }
            return (0..<result.numberOfRanges).map { content.substring(with: result.rangeAt($0)) }
        } catch {
            throw HtmlParserError.regexCreateFailed(pattern)
        }
    }
    
    /// 寻找所有的匹配
    ///
    /// - parameter content: 待匹配的内容
    /// - parameter pattern: 正则表达式字符串
    ///
    /// - throws: 异常类型：RegexError
    ///
    /// - returns: 返回所有匹配正确的字符串数组
    static func matches(in content: String, of pattern: String) throws -> [[String]] {
        do {
            let content = content as NSString
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let results = regex.matches(in: content as String, range: NSRange(location: 0, length: content.length))
            return results.map { result in
                return (0..<result.numberOfRanges).map { content.substring(with: result.rangeAt($0)) }
            }
        } catch {
            throw HtmlParserError.regexCreateFailed(pattern)
        }
    }
}
