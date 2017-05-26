//
//  URL+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

extension URL {
    enum LinkType {
        case `internal`
        case external
        case downloadAttachment
    }
    
    var linkType: LinkType {
        let externalResult = try? Regex.firstMatch(in: absoluteString, of: "https?\\:\\/\\/www\\.hi-pda\\.com\\/forum\\/\\w+")
        if externalResult == nil || externalResult!.count == 0 {
            return .external
        }
        let downloadResult = try? Regex.firstMatch(in: absoluteString, of: "https?:\\/\\/www.hi-pda.com\\/forum\\/attachment\\.php\\?aid=\\w+")
        if downloadResult != nil && downloadResult!.count > 0 {
            return .downloadAttachment
        }
        return .`internal`
    }
}
