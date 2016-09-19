//
//  JSONConvertable.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/18.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// JSON转化为model
protocol JSONDecodable {
    init(_ json: [String: Any]) throws
}
