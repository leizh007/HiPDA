//
//  HomeViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import Moya

/// 主页的ViewController
class HomeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        title = "Discovery"
    }
}
