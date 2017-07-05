//
//  Notification.Name+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

extension Notification.Name {
    /// 主页的tab重复选择
    static let HomeViewControllerTabRepeatedSelected = Notification.Name(rawValue: "HomeViewControllerTabRepeatedSelected")
    
    static let MessageViewControllerTabRepeatedSelected = Notification.Name(rawValue: "MessageViewControllerTabRepeatedSelected")
    
    static let SearchViewControllerTabRepeatedSelected = Notification.Name(rawValue: "SearchViewControllerTabRepeatedSelected")
    
    static let ImageAssetDownloadProgress = Notification.Name(rawValue: "ImageAssetDownloadProgress")
    
    static let ImageAssetsCollectionDidChange = Notification.Name(rawValue: "ImageAssetsCollectionDidChange")
}
