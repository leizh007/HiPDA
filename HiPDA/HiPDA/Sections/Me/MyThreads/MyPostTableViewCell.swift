//
//  MyPostTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class MyPostTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var forumLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    var model: MyPostModel! {
        didSet {
            titleLabel.text = model.title
            contentLabel.text = model.content
            forumLabel.text = "版块: \(model.forumName)"
            timeLabel.text = "回复时间: \(model.postTime)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let maxWidth = C.UI.screenWidth - 16.0
        titleLabel.preferredMaxLayoutWidth = maxWidth
        contentLabel.preferredMaxLayoutWidth = maxWidth
    }
}

extension MyPostTableViewCell: NibLoadableView { }
