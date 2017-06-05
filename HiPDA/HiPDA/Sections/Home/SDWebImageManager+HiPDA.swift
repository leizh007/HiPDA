//
//  SDWebImageManag+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import SDWebImage

typealias ImageDataLoadResult = HiPDA.Result<Data, NSError>
typealias ImageDataLoadCompletion = (ImageDataLoadResult) -> Void

extension SDWebImageManager {
    func loadImageData(with url: URL?, completed completedBlock: ImageDataLoadCompletion? = nil) {
        guard let url = url, let completedBlock = completedBlock else { return }
        SDWebImageManager.shared().loadImage(with: url, options: [.highPriority], progress: nil) { (image, data, error, _, _, _) in
            if let error = error  {
                completedBlock(.failure(error as NSError))
            } else  if let data = data {
                completedBlock(.success(data))
            } else if let image = image {
                DispatchQueue.global().async {
                    if let data = UIImageJPEGRepresentation(image, 1.0) {
                        DispatchQueue.main.async {
                            completedBlock(.success(data))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completedBlock(.failure(NSError(domain: C.URL.HiPDA.image, code: -1, userInfo: nil)))
                        }
                    }
                }
            } else {
                completedBlock(.failure(NSError(domain: C.URL.HiPDA.image, code: -1, userInfo: nil)))
            }
        }
    }
}
