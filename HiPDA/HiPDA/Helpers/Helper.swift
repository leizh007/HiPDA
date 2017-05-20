//
//  Helper.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// Console输出信息
///
/// - parameter message:  输出的信息，非空
/// - parameter filename: 文件名，默认#file
/// - parameter line:     调用改函数所在的行号，默认#line
/// - parameter function: 函数描述，默认#function
func console(message: String, filename: String = #file, line: Int = #line, function: String = #function) {
#if DEBUG
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    let dateString = dateFormatter.string(from: Date())
    print("\(dateString) \((filename as NSString).lastPathComponent):\(line) \(function):  \(message)")
#endif
}

/// 延时执行
///
/// - parameter seconds:    延时时间，单位秒
/// - parameter completion: 延时执行的closure
func delay(seconds: Double, completion:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

// MARK: - Array Convenience Function

/// 数组添加元素
///
/// - Parameters:
///   - lhs: 数组
///   - rhs: 元素
/// - Returns: 返回添加完的数组的拷贝
func +<T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
