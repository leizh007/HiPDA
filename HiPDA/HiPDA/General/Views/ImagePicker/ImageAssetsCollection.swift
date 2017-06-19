//
//  ImageCollection.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/18.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class ImageAssetsCollection {
    private var assets = [ImageAsset]()
    func has(_ asset: ImageAsset) -> Bool {
        return assets.contains(asset)
    }
    
    func index(of asset: ImageAsset) -> Int? {
        return assets.index(of: asset)
    }
    
    func add(_ asset: ImageAsset) {
        if let _ = index(of: asset) {
            remove(asset)
        }
        assets.append(asset)
        postNotification()
    }
    
    func add(_ assets: [ImageAsset]) {
        self.assets.append(contentsOf: assets)
        postNotification()
    }
    
    func remove(_ asset: ImageAsset) {
        guard let index = index(of: asset) else { return }
        assets.remove(at: index)
        postNotification()
        
    }
    
    func removeAllAssets() {
        assets = []
        postNotification()
    }
    
    func getAssets() -> [ImageAsset] {
        return assets
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: .ImageAssetsCollectionDidChange, object: self)
    }
}
