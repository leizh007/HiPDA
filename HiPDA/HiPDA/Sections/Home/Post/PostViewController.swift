//
//  PostViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

/// 帖子网址有两种：
/// https://www.hi-pda.com/forum/viewthread.php?tid=2094735&extra=page%3D1&page=1
/// https://www.hi-pda.com/forum/viewthread.php?tid=2094735&rpid=41821617&ordertype=0&page=1#pid41821617
/// 浏览帖子页面
class PostViewController: BaseViewController {
    var tid: Int!
    var pid: Int?
    var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
