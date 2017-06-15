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
    static func checkPhotoLibraryPermission(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(.authorized)
        case .denied:
            completion(.denied)
        case .restricted:
            completion(.restricted)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion(.authorized)
                    case .denied:
                        completion(.denied)
                    case .restricted:
                        completion(.restricted)
                    case .notDetermined:
                        // won't happen but still
                        completion(.denied)
                    }
                }
            }
        }
    }
}
