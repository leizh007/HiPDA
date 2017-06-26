//
//  SearchUserThreadsTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class SearchUserThreadsTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var forumNameLabel: UILabel!
    @IBOutlet fileprivate weak var readAndReplyCountLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var model: SearchUserThreadModel! {
        didSet {
            timeLabel.text = model.postTime
            forumNameLabel.text = model.forumName
            readAndReplyCountLabel.text = model.replyAndReadCount
            titleLabel.text = model.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.preferredMaxLayoutWidth = C.UI.screenWidth - 2 * 8
    }
}
