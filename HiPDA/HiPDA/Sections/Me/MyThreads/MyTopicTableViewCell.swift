//
//  MyTopicTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class MyTopicTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var forumNameLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var model: MyTopicModel! {
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

extension MyTopicTableViewCell: NibLoadableView { }
