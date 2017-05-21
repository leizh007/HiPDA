//
//  HiPDAURLProtocol.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

class HiPDAURLProtocol: URLProtocol {
    fileprivate static let avatarPlaceholderData: Data = {
        return UIImageJPEGRepresentation(#imageLiteral(resourceName: "avatar_placeholder"), 1.0)!
    }()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return (request.url?.absoluteString.contains(C.URL.HiPDA.avatar) ?? false) ||
            (request.url?.absoluteString.contains(C.URL.HiPDA.image) ?? false)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    override func startLoading() {
        if request.url?.absoluteString.contains(C.URL.HiPDA.avatar) ?? false {
            loadAvatarImage()
        } else if request.url?.absoluteString.contains(C.URL.HiPDA.image) ?? false {
            
        }
    }
    
    override func stopLoading() {
        
    }
}

// MARK: - Handle Image Load

extension HiPDAURLProtocol {
    fileprivate func loadAvatarImage() {
        let response = URLResponse(url: request.url!,
                                   mimeType: "image/jpeg",
                                   expectedContentLength: -1,
                                   textEncodingName: nil)
        let url = URL(string: request.url!.absoluteString.replacingOccurrences(of: C.URL.HiPDA.avatar,
                                                                               with: ""))!
        SDWebImageDownloader.shared().downloadImage(with: url, progress: nil, completed: { [weak self] (_, data, _, _) in
            guard let `self` = self else { return }
            let imageData = data ?? HiPDAURLProtocol.avatarPlaceholderData
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: imageData)
            self.client?.urlProtocolDidFinishLoading(self)
        })
    }
}
