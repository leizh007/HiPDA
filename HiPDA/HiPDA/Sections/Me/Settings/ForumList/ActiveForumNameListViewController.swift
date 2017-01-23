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

/// 版块列表修改完后的回调block
typealias ActiveForumNameListCompletionHandler = ([String]) -> Void

/// 版块列表
class ActiveForumNameListViewController: BaseViewController {
    /// 当前可用的版块列表
    var activeForumNameList = [String]() {
        didSet {
            replaceCommand.onNext(.replace(.init(forumNames: activeForumNameList)))
        }
    }
    
    /// 编辑完后的回调函数
    var completionHandler: ActiveForumNameListCompletionHandler?
    
    /// 替换指令
    fileprivate let replaceCommand = PublishSubject<ActiveForumNameTableViewEditingCommand>()
    
    /// 处理完将要退回上层界面
    fileprivate let willDismiss = PublishSubject<Void>()
    
    /// tableView
    fileprivate let tableView = BaseTableView(frame: .zero, style: .grouped).then {
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height:CGFloat.leastNormalMagnitude))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        guard parent == nil else { return }
        
        willDismiss.onNext(())
    }
}

// MARK: - Configuratons 

extension ActiveForumNameListViewController {
    /// 设置tableView的属性
    fileprivate func configureTableView() {
        view.addSubview(tableView)
    }
}
