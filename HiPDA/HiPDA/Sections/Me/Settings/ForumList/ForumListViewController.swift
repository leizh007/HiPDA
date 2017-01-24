//
//  ForumListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

/// 选择版块列表后的回调block
typealias ForumListChoosenCompletionHandler = ([String]) -> Void

/// 所有版块列表
class ForumListViewController: BaseViewController {
    /// 已选择的版块列表
    var activeForumList = [String]()
    
    /// 选择完后的回调
    var completion: ForumListChoosenCompletionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancel))
        console(message: "\(activeForumList)")
    }
    
    func cancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - StoryboardLoadable

extension ForumListViewController: StoryboardLoadable { }
