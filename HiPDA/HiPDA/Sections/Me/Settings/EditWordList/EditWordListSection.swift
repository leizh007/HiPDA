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

extension EditWordListSection: AnimatableSection {
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

// MARK: - CustomStringConvertible

extension EditWordListSection: CustomStringConvertible {
    var description: String {
        return "EditWordListSection(words:\(words))"
    }
}
