//
//  NewThreadViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class NewThreadViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "发表新帖"
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        let postButton = UIBarButtonItem(title: "发表", style: .plain, target: self, action: #selector(post))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = postButton
    }
    
}

// MARK: - Button Action

extension NewThreadViewController {
    func cancel() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func post() {
        
    }
}

// MARK: - StoryboardLoadable

extension NewThreadViewController: StoryboardLoadable {}
