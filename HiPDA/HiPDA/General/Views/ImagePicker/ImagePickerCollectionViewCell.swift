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
            guard let asset = self.asset else { return }
            asset.getThumbImage(for: CGSize(width: contentView.bounds.size.width * C.UI.screenScale, height: contentView.bounds.size.height * C.UI.screenScale)) { [weak self] result in
                switch result {
                case let .success(image):
                    self?.imageView.image = image
                    self?.stateIndicator.isDownloading = true
                    self?.stateIndicator.downloadProgress = 0.33
                default:
                    break
                }
            }
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
    }
}
