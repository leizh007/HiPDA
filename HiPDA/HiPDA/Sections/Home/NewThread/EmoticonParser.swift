//
//  EmoticonParser.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/20.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYText

class EmoticonParser: YYTextSimpleEmoticonParser {
    private let attachImageRegex = try! NSRegularExpression(pattern: "\\[attachimg\\](\\d+)\\[\\/attachimg\\]", options: .caseInsensitive)
    override func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool {
        if let text = text {
            text.yy_setFont(UIFont.systemFont(ofSize: 17.0), range: text.yy_rangeOfAll())
            text.yy_setColor(.black, range: text.yy_rangeOfAll())
            attachImageRegex.enumerateMatches(in: text.string, options: .withoutAnchoringBounds, range: text.yy_rangeOfAll()) { (result, _, _) in
                guard let result = result else { return }
                let range = result.range
                if range.location == NSNotFound || range.length < 1 {
                    return
                }
                text.yy_setColor(C.Color.navigationBarTintColor, range: range)
            }
        }
        
        return super.parseText(text, selectedRange: selectedRange)
    }
}
