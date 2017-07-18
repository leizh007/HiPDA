//
//  ThreadOrder.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/18.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

extension HiPDA {
    enum ThreadOrder: String {
        case heats
        case dateline
        case replies
        case views
        case lastpost
        
        var descriptionForDisplay: String {
            switch self {
            case .heats:
                return "热门"
            case .dateline:
                return "发帖"
            case .replies:
                return "回复数"
            case .views:
                return "查看数"
            case .lastpost:
                return "回帖"
            }
        }
    }
}
