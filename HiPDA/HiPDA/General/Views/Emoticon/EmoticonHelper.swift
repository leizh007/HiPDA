//
//  EmoticonHelper.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct EmoticonHelper {
    static let groups: [EmoticonGroup] = {
        guard let path = Bundle.main.path(forResource: "Emoticon", ofType: "plist"),
            let arr = NSArray(contentsOfFile: path) as? [NSDictionary] else { return [] }
        return arr.flatMap { dic in
            guard let name = dic["displayName"] as? String,
                let emoticonAttributes = dic["emoticons"] as? [[String: String]] else { return nil }
            return EmoticonGroup(name: name, emoticons: emoticonAttributes.flatMap { emoticonAttribute in
                guard let name = emoticonAttribute["name"],
                    let code = emoticonAttribute["code"] else { return nil }
                return Emoticon(name: name, code: code)
            })
        }
    }()
}
