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
    var completion: ActiveForumNameListCompletionHandler?
    
    /// 替换指令
    fileprivate let replaceCommand = PublishSubject<ActiveForumNameTableViewEditingCommand>()
    
    /// 处理完将要退回上层界面
    fileprivate let willDismiss = PublishSubject<Void>()
    
    /// tableView
    fileprivate let tableView = BaseTableView(frame: .zero, style: .grouped).then { tableView in
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height:CGFloat.leastNormalMagnitude))
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
        super.willMove(toParentViewController: parent)
        
        guard parent == nil else { return }
        
        willDismiss.onNext(())
    }
}

// MARK: - Configuratons 

extension ActiveForumNameListViewController {
    /// 设置tableView的属性
    fileprivate func configureTableView() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<ActiveForumNameSection>()
        skinTableViewDataSource(dataSource)
        
        let deleteCommand = tableView.rx.itemDeleted
            .map(ActiveForumNameTableViewEditingCommand.delete)
        let initialState = ActiveForumNameTableViewState(forumNames: activeForumNameList)
        let data = Observable.of(replaceCommand, deleteCommand)
            .merge()
            .scan(initialState) {
                $0.execute($1)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .shareReplay(1)
        
        data.bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        let itemsCount = data.map { sections in
            return sections.reduce(0) {
                return $0 + $1.items.count
            }
        }
        itemsCount.map {
            $0 == 0 ? .noResult : .normal
        }.bindTo(tableView.rx.status).addDisposableTo(disposeBag)

        willDismiss.withLatestFrom(data).subscribe(onNext: { [unowned self] sections in
            self.completion?(sections[0].items.count == 0 ? ForumManager.defalutForumNameList : sections[0].items)
        }).addDisposableTo(disposeBag)
    }
    
    /// 设置tableView的数据源
    ///
    /// - Parameter dataSource: 数据源
    fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedAnimatedDataSource<ActiveForumNameSection>) {
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left)
        dataSource.configureCell = { (_, tableView, indexPath, item) in
            return (tableView.dequeueReusableCell(for: indexPath) as UITableViewCell).then {
                $0.textLabel?.text = "\(item)"
                $0.selectionStyle = .none
            }
        }
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
    }
}
