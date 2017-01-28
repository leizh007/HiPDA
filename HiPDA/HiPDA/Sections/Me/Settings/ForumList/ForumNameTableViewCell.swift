//
//  ForumNameTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

/// 展示一级版块名称的cell
class ForumNameTableViewCell: UITableViewCell {
    var forumName: String = "" {
        didSet {
            forumNameLabel.text = forumName
        }
    }
    
    @IBOutlet fileprivate var forumNameLabel: UILabel!
}

/// 展示二级版块名称的cell
class ForumNameSecondaryTableViewCell: ForumNameTableViewCell {
}

/// 展示二级版块最后一个名称的cell
class ForumNameSecondaryLastTableViewCell: ForumNameTableViewCell {
}

