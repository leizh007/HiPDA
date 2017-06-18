//
//  ImageAsset.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Photos
import SDWebImage

typealias ImageAssetResult = HiPDA.Result<UIImage, NSError>

enum DownloadedAsset {
    case image(UIImage)
    case gif(Data)
}

class ImageAsset {
    let asset: PHAsset
    private var thumbnailImage: UIImage?
    private var imageRequestID = PHInvalidImageRequestID
    private var downloadedAsset: DownloadedAsset?
    var downloadPercent = 0.0
    var isDownloading: Bool {
        return downloadedAsset == nil && downloadPercent < 1.0 && imageRequestID != PHInvalidImageRequestID
    }
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func getThumbImage(for size: CGSize, completion: @escaping (ImageAssetResult) -> Void) {
        if let thumbnailImage = thumbnailImage {
            completion(.success(thumbnailImage))
            return
        }
        
        imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { [weak self] (image, info) in
            guard let `self` = self else { return }
            if image == nil {
                if let error = info?[PHImageErrorKey] as? NSError {
                    self.cancelDownloading()
                    completion(.failure(error))
                } else {
                    completion(.success(UIImage()))
                }
                return
            }
            completion(.success(image!))
        }
    }
    
    func downloadAsset(completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        if downloadedAsset != nil {
            completion(.success(""))
            return
        }
        if imageRequestID != PHInvalidImageRequestID {
            cancelDownloading()
        }
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .original
        options.isSynchronous = false
        options.progressHandler = { [weak self] (progress, error, _, info) in
            guard let `self` = self else { return }
            guard self.imageRequestID != PHInvalidImageRequestID else { return }
            self.downloadPercent = progress
            if progress < 1.0 {
                NotificationCenter.default.post(name: .ImageAssetDownloadProgress, object: self)
            }
        }
        imageRequestID = PHImageManager.default().requestImageData(for: asset, options: options) { [weak self] (data, _, _, info) in
            guard let `self` = self else { return }
            guard let data = data, let image = UIImage(data: data) else {
                if let error = info?[PHImageErrorKey] as? NSError {
                    self.cancelDownloading()
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "HiPDA-Image-Selection", code: -1, userInfo: [NSLocalizedDescriptionKey: "下载图片出错"])))
                }
                return
            }
            let type = NSData.sd_imageFormat(forImageData: data)
            switch type {
            case .GIF:
                self.downloadedAsset = .gif(data)
            default:
                self.downloadedAsset = .image(image)
            }
            completion(.success(""))
        }
    }
    
    func cancelDownloading() {
        guard imageRequestID != PHInvalidImageRequestID else { return }
        PHImageManager.default().cancelImageRequest(imageRequestID)
        imageRequestID = PHInvalidImageRequestID
    }
}
