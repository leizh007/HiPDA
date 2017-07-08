//
//  AttentionViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class AttentionViewController: FavoritesAndAttentionBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的关注"
    }
    
    override func skinViewModel() {
        viewModel = AttentionViewModel(type: .attention)
    }
}
