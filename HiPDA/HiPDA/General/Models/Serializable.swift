//
//  Serializable.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 可序列化
protocol Serializable {
    /// 初始化方法
    init(_ data: Data)
    
    /// 编码为Data
    func encode() -> Data
}
