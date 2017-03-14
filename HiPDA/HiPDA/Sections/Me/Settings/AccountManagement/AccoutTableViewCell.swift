//
//  AccoutTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/12.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

class AccoutTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var uidLabel: UILabel!
    @IBOutlet fileprivate weak var userNameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.sd_cancelCurrentImageLoad()
    }
    
    var cellModel: AccountCellModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }
            userNameLabel.text = cellModel.name
            uidLabel.text = cellModel.uid
            avatarImageView.sd_setImage(with: cellModel.avatarImageURL)
            accessoryType = cellModel.accessoryType
        }
    }
}
