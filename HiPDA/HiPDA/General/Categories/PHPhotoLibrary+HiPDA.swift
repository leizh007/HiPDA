//
//  PHPhotoLibrary+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Photos

extension PHPhotoLibrary {
    static func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
        case .restricted:
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion(true)
                    case .denied:
                        completion(false)
                    case .restricted:
                        completion(false)
                    case .notDetermined:
                        // won't happen but still
                        completion(false)
                    }
                }
            }
        }
    }
}
