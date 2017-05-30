//
//  ImageUtils.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import SDWebImage

typealias ImageManipulationResult = Result<Void, NSError>

class ImageUtils: NSObject {
    static func copyImage(url: String, completion: @escaping (ImageManipulationResult) -> Void) {
        SDWebImageManager.shared().loadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, _, error, _, _, _) in
            if let image = image {
                UIPasteboard.general.image = image
            }
            if let error = error {
                completion(.failure(error as NSError))
            } else {
                completion(.success(()))
            }
        })
    }
    
    var completion: ((ImageManipulationResult) -> Void)?
    
    func saveImage(url: String, completion: @escaping (ImageManipulationResult) -> Void) {
        SDWebImageManager.shared().loadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, _, error, _, _, _) in
            guard let image = image, error == nil else {
                let error = error ?? NSError(domain: C.URL.HiPDA.image, code: -1, userInfo: nil)
                completion(.failure(error  as NSError))
                return
            }
            self.completion = completion
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            completion?(.failure(error as NSError))
        } else {
            completion?(.success(()))
        }
        completion = nil
    }
}
