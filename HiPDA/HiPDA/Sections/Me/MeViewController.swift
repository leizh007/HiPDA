//
//  MeViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 我的ViewController
class MeViewController: BaseViewController {
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        navigationItem.title = "个人中心"
    }
}
