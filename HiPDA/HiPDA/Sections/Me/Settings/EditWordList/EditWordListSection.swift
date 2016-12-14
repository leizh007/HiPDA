//
//  EditWordListSection.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/14.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxDataSources

/// 编辑词组TableView的section模型
struct EditWordListSection {
    var words: [String]
}

// MARK: - AnimatableSectionModelType

extension EditWordListSection: AnimatableSectionModelType {
    typealias Item = String
    typealias Identity = String
    
    var identity: String {
        return "\(words)"
    }
    
    var items: [String] {
        return words
    }
    
    init(original: EditWordListSection, items: [Item]) {
        self = original
        self.words = items
    }
}

// MARK: - Equatable

extension EditWordListSection: Equatable {
    static func ==(lhs: EditWordListSection, rhs: EditWordListSection) -> Bool {
        if lhs.items.count != rhs.items.count {
            return false
        }
        
        return (0..<lhs.items.count).reduce(true) {
            $0 && (lhs.items[$1] == rhs.items[$1])
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension EditWordListSection: CustomDebugStringConvertible {
    var debugDescription: String {
        return "EditWordListSection(words:\(words))"
    }
}
