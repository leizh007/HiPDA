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
    private static var regexCache = [String: NSRegularExpression]()
    private static let lock = NSRecursiveLock()
    
    /// 获取正则表达式
    ///
    /// - Parameter pattern: 正则表达式字符串
    /// - Returns: 正则表达式
    /// - Throws: 创建失败异常
    static func regularExpression(of pattern: String) throws -> NSRegularExpression {
        lock.lock()
        defer {
            lock.unlock()
        }
        let regex: NSRegularExpression
        if let value = Regex.regexCache[pattern] {
            regex = value
        } else {
            do {
                regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                Regex.regexCache[pattern] = regex
            } catch {
                throw HtmlParserError.regexCreateFailed(pattern)
            }
        }
        
        return regex
    }
    
    /// 寻找第一个匹配
    ///
    /// - parameter content: 待匹配的内容
    /// - parameter pattern: 正则表达式字符串
    ///
    /// - throws: 异常类型：HtmlParserError
    ///
    /// - returns: 返回第一个匹配正确的字符串数组
    static func firstMatch(in content: String, of pattern: String) throws -> [String] {
        let content = content as NSString
        let regex = try Regex.regularExpression(of: pattern)
        guard let result = regex.firstMatch(in: content as String, range: NSRange(location: 0, length: content.length)) else {
            return []
        }
        return (0..<result.numberOfRanges).map { index in
            return result.rangeAt(index).location != NSNotFound ? content.substring(with: result.rangeAt(index)) : ""
        }
    }
    
    /// 寻找所有的匹配
    ///
    /// - parameter content: 待匹配的内容
    /// - parameter pattern: 正则表达式字符串
    ///
    /// - throws: 异常类型：HtmlParserError
    ///
    /// - returns: 返回所有匹配正确的字符串数组
    static func matches(in content: String, of pattern: String) throws -> [[String]] {
        let content = content as NSString
        let regex = try Regex.regularExpression(of: pattern)
        let results = regex.matches(in: content as String, range: NSRange(location: 0, length: content.length))
        return results.map { result in
            return (0..<result.numberOfRanges).map { index in
                return result.rangeAt(index).location != NSNotFound ? content.substring(with: result.rangeAt(index)) : ""
            }
        }
    }
}
