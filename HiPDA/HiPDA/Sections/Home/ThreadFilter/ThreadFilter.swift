//
//  ThreadFilter.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

struct ThreadFilter {
    let typeName: String
    let order: ThreadOrder
}

// MARK: - Serializable

extension ThreadFilter: Serializable { }

// MARK: - Decodable

extension ThreadFilter: Decodable {
    static func decode(_ json: JSON) -> Decoded<ThreadFilter> {
        return curry(ThreadFilter.init(typeName:order:))
            <^> json <| "typeName"
            <*> json <| "order"
    }
}

// MARK: - Equalable

extension ThreadFilter: Equatable {
    static func ==(lhs: ThreadFilter, rhs: ThreadFilter) -> Bool {
        return lhs.typeName == rhs.typeName && lhs.order.rawValue == rhs.order.rawValue
    }
}

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
    
    static func order(from description: String) -> ThreadOrder? {
        switch description {
        case ThreadOrder.heats.descriptionForDisplay:
            return .heats
        case ThreadOrder.dateline.descriptionForDisplay:
            return .dateline
        case ThreadOrder.replies.descriptionForDisplay:
            return .replies
        case ThreadOrder.views.descriptionForDisplay:
            return .views
        case ThreadOrder.lastpost.descriptionForDisplay:
            return .lastpost
        default:
            return nil
        }
    }
    
    static let allOrderDescriptions = [ThreadOrder.heats.descriptionForDisplay,
                                       ThreadOrder.dateline.descriptionForDisplay,
                                       ThreadOrder.replies.descriptionForDisplay,
                                       ThreadOrder.views.descriptionForDisplay,
                                       ThreadOrder.lastpost.descriptionForDisplay]

}

extension ThreadOrder: Serializable { }

// MARK: - Decodable

extension ThreadOrder: Decodable { }
