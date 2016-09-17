//
//  LoginNameTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/17.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

class LoginNameTableViewCell: UITableViewCell {
    /// 展示用户姓名的Label
    @IBOutlet private weak var nameLabel: UILabel!
    
    /// 姓名
    var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            backgroundColor = UIColor(red:0.908, green:0.908, blue:0.908, alpha:1)
        } else {
            backgroundColor = UIColor(red:0.965, green:0.965, blue:0.965, alpha:1)
        }
    }
}
