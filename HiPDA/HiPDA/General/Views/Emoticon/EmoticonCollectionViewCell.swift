//
//  EmoticonCellCollectionViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/12.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import YYImage

class EmoticonCollectionViewCell: UICollectionViewCell {
    var emoticon: Emoticon? {
        didSet {
            if emoticon != oldValue {
                updateContent()
            }
        }
    }
    var isDelete: Bool = false {
        didSet {
            if isDelete != oldValue {
                updateContent()
            }
        }
    }
    var imageView: YYAnimatedImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = YYAnimatedImageView(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateLayout()
    }
    
    fileprivate func updateContent() {
        if (isDelete) {
            imageView.image = #imageLiteral(resourceName: "emotion_delete")
        } else if let emoticon = emoticon {
            imageView.image = YYImage(named: emoticon.name)
            imageView.contentMode = max(imageView.frame.size.width, imageView.frame.size.height) > max(imageView.image?.size.width ?? 0, imageView.image?.size.height ?? 0) ? .center : .scaleAspectFit
        } else {
            imageView.image = nil
        }
    }
    
    fileprivate func updateLayout() {
        imageView.center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
    }
}
