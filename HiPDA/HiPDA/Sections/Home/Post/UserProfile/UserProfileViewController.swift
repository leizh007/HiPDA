//
//  UerProfileViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(user.name)的个人资料"
    }
}
