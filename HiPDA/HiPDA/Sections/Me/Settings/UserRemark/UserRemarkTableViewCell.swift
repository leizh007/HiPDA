//
//  UserRemarkTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/21.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 用户备注的cell
class UserRemarkTableViewCell: UITableViewCell {
    /// 用户名
    @IBOutlet private weak var userNameLabel: UILabel!
    
    /// 用户备注名
    @IBOutlet private weak var remarkNameLabel: UILabel!
    
    /// 用户备注
    var userRemark: UserRemark? {
        didSet {
            userNameLabel.text = userRemark?.userName ?? ""
            remarkNameLabel.text = userRemark?.remarkName ?? ""
        }
    }
}

// MARK: - NibLoadableView

extension UserRemarkTableViewCell: NibLoadableView {
    
}
