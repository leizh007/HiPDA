//
//  ForumListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

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
        
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        
        let cancel = UIBarButtonItem(title: "取消", style: .plain, target: nil, action: nil)
        cancel.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        navigationItem.leftBarButtonItem = cancel
        
        let confirm = UIBarButtonItem(title: "确定", style: .plain, target: nil, action: nil)
        confirm.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: true) {
                self.completion?(self.activeForumList)
            }
        }).addDisposableTo(disposeBag)
        navigationItem.rightBarButtonItem = confirm
    }
}

// MARK: - StoryboardLoadable

extension ForumListViewController: StoryboardLoadable { }
