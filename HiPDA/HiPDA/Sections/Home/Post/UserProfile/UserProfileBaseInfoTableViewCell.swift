//
//  UserProfileBaseInfoTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class UserProfileBaseInfoTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var valueLabel: UILabel!
    var baseInfo: ProfileBaseInfo! {
        didSet {
            nameLabel.text = baseInfo.name
            valueLabel.text = baseInfo.value
        }
    }
}
