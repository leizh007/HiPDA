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
        print("\((filename as NSString).lastPathComponent):\(line) \(function):  \(message)")
    #endif
}

/// 延时执行
///
/// - parameter seconds:    延时时间，单位秒
/// - parameter completion: 延时执行的closure
func delay(seconds: Double, completion:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}
