//
//  ImagePickerDataSource.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Photos

class ImagePickerDataSource {
    var assets = [ImageAsset]()
    
    func loadAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResults = PHAsset.fetchAssets(with: .image, options: options)
        assets = []
        assets.reserveCapacity(fetchResults.count)
        fetchResults.enumerateObjects(_:) { (asset, _, _) in
            self.assets.append(ImageAsset(asset: asset))
        }
    }
}
