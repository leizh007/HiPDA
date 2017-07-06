//
//  SearchFulltextTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class SearchFulltextTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var forumNameLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var readCountLabel: UILabel!
    @IBOutlet fileprivate weak var replyCountLabel: UILabel!
    
    var model: SearchFulltextModelForUI! {
        didSet {
            titleLabel.text = model.title
            contentLabel.attributedText = model.content
            usernameLabel.text = "作者: \(model.user.name)"
            forumNameLabel.text = "版块: \(model.forumName)"
            timeLabel.text = model.time
            readCountLabel.text = "查看: \(model.readCount)"
            replyCountLabel.text = "回复: \(model.replyCount)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentLabel.preferredMaxLayoutWidth = C.UI.screenWidth - 16.0
    }
}
