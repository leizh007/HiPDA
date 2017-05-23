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
        if request.url!.absoluteString.contains(C.URL.HiPDA.avatar) {
            loadAvatarImage()
        } else if request.url!.absoluteString.contains(C.URL.HiPDA.image) {
            loadAttatchImage()
        }
    }
    
    override func stopLoading() {
        
    }
}

// MARK: - Handle Image Load

extension HiPDAURLProtocol {
    fileprivate func loadAvatarImage() {
        loadImage(url: request.url!, imageFlag: C.URL.HiPDA.avatar, placeHolderData: HiPDAURLProtocol.avatarPlaceholderData)
    }
    
    fileprivate func loadAttatchImage() {
        loadImage(url: request.url!, imageFlag: C.URL.HiPDA.image, placeHolderData: nil)
    }
    
    fileprivate func loadImage(url: URL, imageFlag: String, placeHolderData: Data?) {
        let response = URLResponse(url: url,
                                   mimeType: "image/jpeg",
                                   expectedContentLength: -1,
                                   textEncodingName: nil)
        let url = URL(string: request.url!.absoluteString.replacingOccurrences(of: imageFlag,
                                                                               with: ""))!
        SDWebImageManager.shared().loadImageData(with: url) { [weak self] result in
            guard let `self` = self else { return }
            let successBlock: (Data) -> Void = { data in
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            }
            switch result {
            case .success(let data):
                successBlock(data)
            case .failure(let error):
                if let data = placeHolderData {
                    successBlock(data)
                } else {
                    self.client?.urlProtocol(self, didFailWithError: error)
                }
            }
        }
    }
}
