//
//  UserProfileAccountTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

class UserProfileAccountTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var uidLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.borderWidth = 1.0 / C.UI.screenScale
        avatarImageView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
    }
    
    var user: User! {
        didSet {
            nameLabel.text = user.name
            uidLabel.text = "UID: \(user.uid)"
            avatarImageView.sd_setImage(with: user.avatarImageURL, placeholderImage: #imageLiteral(resourceName: "avatar_placeholder"))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.sd_cancelCurrentImageLoad()
    }
}
