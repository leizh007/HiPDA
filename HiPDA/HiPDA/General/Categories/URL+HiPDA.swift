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
        case viewThread
        case redirect
        case userProfile
    }
    
    var linkType: LinkType {
        let externalResult = try? Regex.firstMatch(in: absoluteString, of: "https?:\\/\\/\\w+\\.hi-pda\\.com\\/forum")
        if externalResult == nil || externalResult!.count == 0 {
            return .external
        }
        let downloadResult = try? Regex.firstMatch(in: absoluteString, of: "https?:\\/\\/\\w+\\.hi-pda\\.com\\/forum\\/attachment\\.php\\?aid=\\w+")
        if downloadResult != nil && downloadResult!.count > 0 {
            return .downloadAttachment
        }
        if let _ = PostInfo(urlString: absoluteString) {
            return .viewThread
        }
        let redirectResult = try? Regex.firstMatch(in: absoluteString, of: "https?:\\/\\/\\w+\\.hi-pda\\.com\\/forum\\/redirect\\.php\\?\\w+")
        if redirectResult != nil && redirectResult!.count > 0 {
            return .redirect
        }
        let userProfile = try? Regex.firstMatch(in: absoluteString, of: "https?:\\/\\/\\w+\\.hi-pda\\.com\\/forum\\/space\\.php\\?uid=\\d+")
        if userProfile != nil && userProfile!.count > 0 {
            return .userProfile
        }
        
        return .`internal`
    }
    
    var canOpenInAPP: Bool {
        return linkType == .viewThread || linkType == .redirect || linkType == .userProfile
    }
}
