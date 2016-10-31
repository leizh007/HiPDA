//
//  Optional+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/31.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 空值错误
struct NilError: Error {
    fileprivate let _description: String
    init(file: String, line: Int) {
        _description = "Nil returned at "
            + (file as NSString).lastPathComponent
            + ":\(line)"
    }
}

extension NilError: CustomStringConvertible {
    var description: String {
        return _description
    }
}

/// http://swift.gg/2016/10/31/converting-optionals-to-thrown-errors/
extension Optional {
    
    /// 获取unWrapped的值
    ///
    /// - Parameters:
    ///   - file: 文件
    ///   - line: 行号
    /// - Returns: 返回unWrapped的值
    /// - Throws: 如果为nil抛出NilError类型的异常
    func dematerialize(file: String = #file, line: Int = #line) throws -> Wrapped {
        guard let unwrapped = self else { throw NilError(file: file, line: line) }
        return unwrapped
    }
}
