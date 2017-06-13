//
//  Emoticon.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/12.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct EmoticonGroup {
    let name: String
    let emoticons: [Emoticon]
}

struct Emoticon {
    let name: String
    let code: String
}

extension Emoticon: Equatable {
    static func ==(lhs: Emoticon, rhs: Emoticon) -> Bool {
        return lhs.name == rhs.name && lhs.code == rhs.code
    }
}
