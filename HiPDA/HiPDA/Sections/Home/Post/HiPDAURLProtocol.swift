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
    
    fileprivate static let webViewImagePlaceholderData: Data = {
        return UIImagePNGRepresentation(#imageLiteral(resourceName: "webView_image_placeholder"))!
    }()
    
    fileprivate static let imageLoadingData: Data = {
        let loadingGIFPath = Bundle.main.path(forResource: "image_loading_spinner", ofType: "gif")!
        return try! Data(contentsOf: URL(fileURLWithPath: loadingGIFPath))
    }()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
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
        } else if request.url!.absoluteString.contains(C.URL.HiPDA.imagePlaceholder) {
            loadImagePlaceholder()
        } else if request.url!.absoluteString.contains(C.URL.HiPDA.image) {
            loadAttatchImage()
        } else if request.url!.absoluteString.contains(C.URL.HiPDA.imageLoading) {
            loadImageLoadingImage()
        } else {
            // 其他图片禁止加载
            client?.urlProtocol(self, didFailWithError: NSError(domain: C.URL.HiPDA.image, code: -1, userInfo: nil))
        }
    }
    
    override func stopLoading() {
        
    }
}

// MARK: - Handle Image Load

extension HiPDAURLProtocol {
    fileprivate func loadAvatarImage() {
        loadImage(url: request.url!, imageFlag: C.URL.HiPDA.avatar, placeHolderData: Settings.shared.useAvatarPlaceholder ? HiPDAURLProtocol.avatarPlaceholderData : nil)
    }
    
    fileprivate func loadAttatchImage() {
        loadImage(url: request.url!, imageFlag: C.URL.HiPDA.image, placeHolderData: nil)
    }
    
    fileprivate func loadImagePlaceholder() {
        loadImage(data: HiPDAURLProtocol.webViewImagePlaceholderData)
        
    }
    
    fileprivate func loadImageLoadingImage() {
        loadImage(data: HiPDAURLProtocol.imageLoadingData)
    }
    
    fileprivate func loadImage(data: Data) {
        let response = URLResponse(url: request.url!,
                                   mimeType: "image/jpeg",
                                   expectedContentLength: -1,
                                   textEncodingName: nil)
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        self.client?.urlProtocolDidFinishLoading(self)
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
