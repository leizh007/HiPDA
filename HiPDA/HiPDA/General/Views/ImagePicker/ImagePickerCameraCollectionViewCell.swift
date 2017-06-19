//
//  ImagePickerCameraCollectionViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class ImagePickerCameraCollectionViewCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    private var imageView: UIImageView!
    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        image = nil
    }
}
