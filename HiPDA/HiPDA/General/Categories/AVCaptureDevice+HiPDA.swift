//
//  AVCaptureDevice+Swift.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    static func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
        case .restricted:
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
}
