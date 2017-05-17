//
//  PostViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

/// 浏览帖子页面
class PostViewController: BaseViewController {
    var postInfo: PostInfo!
    fileprivate var viewModel: PostViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PostViewModel(postInfo: postInfo)
    }
}
