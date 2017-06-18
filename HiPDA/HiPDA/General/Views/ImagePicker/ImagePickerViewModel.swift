//
//  ImagePickerViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 图片压缩大小
///
/// - twoHundredKB: ~200KB
/// - fourHundredKB: ~400KB
/// - eightHundredKB: ~800KB
/// - original: 原图
enum ImageCompressType: Int {
    case twoHundredKB = 0
    case fourHundredKB
    case eightHundredKB
    case original
}

class ImagePickerViewModel {
    var imageCompressType = ImageCompressType.original
    let dataSource = ImagePickerDataSource()
    
    func loadAssets() {
        dataSource.loadAssets()
    }
}

// MARK: - UICollectionViewDataSource Related

extension ImagePickerViewModel {
    func numberOfItems() -> Int {
        return dataSource.assets.count
    }
    
    func asset(at index: Int) -> ImageAsset {
        return dataSource.assets[index]
    }
}
