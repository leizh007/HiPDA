//
//  UserProfileActionTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class UserProfileActionTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var actionLabel: UILabel!
    var action: String {
        get {
            return actionLabel.text ?? ""
        }
        set {
            actionLabel.text = newValue
        }
    }
}
