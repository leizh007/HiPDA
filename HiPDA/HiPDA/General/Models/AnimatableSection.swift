//
//  AnimatableSection.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// AnimatableSection
protocol AnimatableSection: AnimatableSectionModelType, Equatable {
    var header: String { get }
}

extension AnimatableSection {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.items.count == rhs.items.count &&
            lhs.header == rhs.header &&
            (0..<lhs.items.count).reduce(true) {
            $0 && (lhs.items[$1] == rhs.items[$1])
        }
    }
}
