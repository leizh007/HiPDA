//
//  ForumListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

/// 所有版块列表
class ForumListViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancel))
    }
    
    func cancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
