//
//  ThreadFilterTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class ThreadFilterTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var isItemSelected: Bool! {
        didSet {
            if isItemSelected {
                accessoryType = .checkmark
                titleLabel.textColor = C.Color.navigationBarTintColor
            } else {
                titleLabel.textColor = .black
                accessoryType = .none
            }
        }
    }
}
