//
//  DraftTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class DraftTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var forumNameLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var model: Draft! {
        didSet {
            forumNameLabel.text = model.forumName
            timeLabel.text = model.time
            titleLabel.text = model.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.preferredMaxLayoutWidth = C.UI.screenWidth - 16.0
    }
}
