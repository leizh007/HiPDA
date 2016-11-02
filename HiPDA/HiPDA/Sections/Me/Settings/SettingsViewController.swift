//
//  SettingsViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/2.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 设置
class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = "设置"
    }
}
