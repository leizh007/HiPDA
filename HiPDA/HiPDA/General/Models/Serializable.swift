//
//  Serializable.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import HandyJSON

/// 可序列化
protocol Serializable {
    /// 编码为String
    func encode() -> String
}

extension Serializable {
    func encode() -> String {
        guard let result = JSONSerializer.serializeToJSON(object: self) else {
            fatalError("\(type(of: self)): \(self) cannot encode to String!")
        }
        
        return result
    }
}
