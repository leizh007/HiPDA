//
//  ImagePickerCollectionViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/18.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class ImagePickerCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var stateIndicator: ImageSelectorStateIndicator!
    var asset: ImageAsset? {
        didSet {
            if let oldAsset = oldValue {
                unsubscribeToDownloadProgressNotification(oldAsset)
            }
            guard let asset = self.asset else { return }
            subscribeToDownloadProgressNotification(asset)
            asset.getThumbImage(for: CGSize(width: contentView.bounds.size.width * C.UI.screenScale, height: contentView.bounds.size.height * C.UI.screenScale)) { [weak self] result in
                switch result {
                case let .success(image):
                    self?.imageView.image = image
                default:
                    break
                }
            }
        }
    }
    
    var assetsCollection: ImageAssetsCollection? {
        didSet {
            if let oldCollection = oldValue {
                unsubscribeToAssetsCollectionDidChange(oldCollection)
            }
            guard let assetsCollection = assetsCollection else { return }
            subscribeToAssetsCollectionDidChange(assetsCollection)
        }
    }
    
    func updateState() {
        guard let asset = asset, let assetsCollection = assetsCollection else {
            stateIndicator.clearState()
            return
        }
        stateIndicator.isDownloading = asset.isDownloading
        stateIndicator.downloadProgress = asset.downloadPercent
        if let index = assetsCollection.index(of: asset) {
            stateIndicator.selectionNumber = index + 1
        } else {
            stateIndicator.selectionNumber = 0
        }
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        stateIndicator = ImageSelectorStateIndicator(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(stateIndicator)
        contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        stateIndicator.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        asset?.cancelDownloading()
        if let asset = asset {
            unsubscribeToDownloadProgressNotification(asset)
        }
        if let collection = assetsCollection {
            unsubscribeToAssetsCollectionDidChange(collection)
        }
        stateIndicator.clearState()
    }
    
    deinit {
        asset?.cancelDownloading()
        if let asset = asset {
            unsubscribeToDownloadProgressNotification(asset)
        }
        if let collection = assetsCollection {
            unsubscribeToAssetsCollectionDidChange(collection)
        }
    }
    
    fileprivate func subscribeToDownloadProgressNotification(_ asset: ImageAsset) {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDownloadProgressNotification(_:)), name: .ImageAssetDownloadProgress, object: asset)
    }
    
    fileprivate func unsubscribeToDownloadProgressNotification(_ asset: ImageAsset) {
        NotificationCenter.default.removeObserver(self, name: .ImageAssetDownloadProgress, object: asset)
    }
    
    func didReceiveDownloadProgressNotification(_ notification: Notification) {
        guard let asset = asset else { return }
        let isDownloading = asset.isDownloading
        let progress = asset.downloadPercent
        let isSelected = stateIndicator.isSelected
        if (!isSelected) {
            stateIndicator.downloadProgress = progress
            stateIndicator.isDownloading = isDownloading
        }
    }
    
    fileprivate func subscribeToAssetsCollectionDidChange(_ assetsCollection: ImageAssetsCollection) {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedAssetsCollectionChangedNotification(_:)), name: .ImageAssetsCollectionDidChange, object: assetsCollection)
    }
    
    fileprivate func unsubscribeToAssetsCollectionDidChange(_ assetsCollection: ImageAssetsCollection) {
        NotificationCenter.default.removeObserver(self, name: .ImageAssetsCollectionDidChange, object: assetsCollection)
    }
    
    func didReceivedAssetsCollectionChangedNotification(_ notification: Notification) {
        guard let asset = asset, !asset.isDownloading else { return }
        if let index = assetsCollection?.index(of: asset) {
            stateIndicator.selectionNumber = index + 1
        } else {
            stateIndicator.selectionNumber = 0
        }
    }
}
