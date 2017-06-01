//
//  ImageUtils.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import SDWebImage
import Photos

typealias ImageManipulationResult = Result<String, NSError>

class ImageUtils {
    static func copyImage(url: String, completion: @escaping (ImageManipulationResult) -> Void) {
        SDWebImageManager.shared().loadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, _, error, _, _, _) in
            if let image = image {
                UIPasteboard.general.image = image
            }
            if let error = error {
                completion(.failure(error as NSError))
            } else {
                completion(.success(""))
            }
        })
    }
    
    static func saveImage(url: String, completion: @escaping (ImageManipulationResult) -> Void) {
        SDWebImageManager.shared().loadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, _, error, _, _, _) in
            guard let _ = image, error == nil, let url = SDImageCache.shared().defaultCachePath(forKey: url) else {
                let error = error ?? NSError(domain: C.URL.HiPDA.image, code: -1, userInfo: nil)
                completion(.failure(error  as NSError))
                return
            }
            let fileURL = URL(fileURLWithPath: url)
            PHPhotoLibrary.shared().performChanges({ 
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
            }, completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error as NSError))
                    } else {
                        completion(.success(""))
                    }
                }
            })
        })
    }
    
    static func qrcode(from url: String, completion: @escaping (ImageManipulationResult) -> Void) {
        SDWebImageManager.shared().loadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, _, error, _, _, _) in
            guard let image = image, error == nil else {
                let error = error ?? NSError(domain: C.URL.HiPDA.image, code: -1, userInfo: nil)
                completion(.failure(error  as NSError))
                return
            }
            if let qrCode = ImageUtils.qrCodeFromImage(qrImage: image) {
                completion(.success(qrCode))
            } else {
                completion(.failure(NSError(domain: "HiPDA-QrCode", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有识别到二维码"])))
            }
        })
    }
    
    // https://stackoverflow.com/questions/34205773/not-detecting-qr-code-from-a-static-image
     static func qrCodeFromImage(qrImage:UIImage) -> String? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        guard let ciImage = qrImage.ciImage() else {
            return nil
        }
        guard let feature = detector?.features(in: ciImage).last as? CIQRCodeFeature else {
            return nil
        }
        return feature.messageString
    }
}
