//
//  UITextInput+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/7.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

extension UITextInput {
    /// 未标记的文本
    var nonMarkedText: String? {
        let start = beginningOfDocument
        let end = endOfDocument
        
        guard let rangeAll = textRange(from: start, to: end),
            let textString = text(in: rangeAll) else {
                return nil
        }
        
        guard let markedTextRange = markedTextRange else {
            return textString
        }
        
        guard let startRange = textRange(from: start, to: markedTextRange.start),
            let endRange = textRange(from: markedTextRange.end, to: end) else {
                return textString
        }
        
        return (text(in: startRange) ?? "") + (text(in: endRange) ?? "")
    }
}
