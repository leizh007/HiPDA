//
//  FavoritesAndAttentionBaseTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class FavoritesAndAttentionBaseTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var forumNameLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var model: FavoritesAndAttentionBaseModel! {
        didSet {
            forumNameLabel.text = model.forumName
            titleLabel.text = model.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.preferredMaxLayoutWidth = C.UI.screenWidth - 16.0
    }
}

extension FavoritesAndAttentionBaseTableViewCell: NibLoadableView { }
