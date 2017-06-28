//
//  FriendMessageTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class FriendMessageTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    var time: String! {
        didSet {
            timeLabel.text = time
        }
    }
    var isRead: Bool = false {
        didSet {
            titleLabel.textColor = isRead ? #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
    }
}

extension FriendMessageTableViewCell: NibLoadableView { }
