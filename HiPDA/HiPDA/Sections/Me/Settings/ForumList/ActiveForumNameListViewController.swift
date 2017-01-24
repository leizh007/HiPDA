//
//  ActiveForumNameListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

/// 版块列表
class ActiveForumNameListViewController: EditWordListViewController {
    /// 当前可用的版块列表
    var activeForumNameList = [String]() {
        didSet {
            words = activeForumNameList
        }
    }
}

// MAARK: - Configurations

extension ActiveForumNameListViewController {
    /// 设置添加按钮
    override func configureAddBarButtonItem() {
        addBarButtonItem.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.tableView.setEditing(false, animated: true)
            let forumListVC = ForumListViewController()
            let navigationController = UINavigationController(rootViewController: forumListVC)
            navigationController.transitioningDelegate = self
            self.present(navigationController, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}
