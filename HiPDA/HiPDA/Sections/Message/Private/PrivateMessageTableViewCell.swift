//
//  PrivateMessageTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

class PrivateMessageTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var redPointView: UIView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    var user: User! {
        didSet {
            nameLabel.text = user.name
            avatarImageView.sd_setImage(with: user.avatarImageURL, placeholderImage: #imageLiteral(resourceName: "avatar_placeholder"))
        }
    }
    
    var content: String! {
        didSet {
            contentLabel.text = content
        }
    }
    
    var time: String! {
        didSet {
            timeLabel.text = time
        }
    }
    
    var isRead: Bool! {
        didSet {
            redPointView.isHidden = isRead
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.sd_cancelCurrentImageLoad()
    }
}

extension PrivateMessageTableViewCell: NibLoadableView { }
