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
    
    /// tableView
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    /// VC将要消失
    fileprivate let willDismiss = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
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
            self.presentingViewController?.dismiss(animated: true) { _ in
                self.willDismiss.onNext(())
            }
        }).addDisposableTo(disposeBag)
        navigationItem.rightBarButtonItem = confirm
    }
}

// MARK: - StoryboardLoadable

extension ForumListViewController: StoryboardLoadable { }

// MARK: - Configurations

extension ForumListViewController {
    /// 设置tabelView
    fileprivate func configureTableView() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height:CGFloat.leastNormalMagnitude))
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<ForumNameSection>()
        skinTableViewDataSource(dataSource)
        
        let viewModel = ForumListViewModel(activeForumList: activeForumList, selection: tableView.rx.itemSelected.asDriver())
        viewModel.sections.drive(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        willDismiss.withLatestFrom(viewModel.selectedForumList)
            .subscribe(onNext: { [unowned self] forumList in
                self.completion?(forumList)
            }).addDisposableTo(disposeBag)
    }
    
    /// 设置tableView的数据源
    ///
    /// - Parameter dataSource: 数据源
    fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<ForumNameSection>) {
        dataSource.configureCell = { [unowned self] (_, tableView, indexPath, item) in
            let cell: ForumNameTableViewCell
            switch item.level {
            case .first:
                cell = (tableView.dequeueReusableCell(for: indexPath) as ForumNameTableViewCell)
            case .secondary:
                cell = (tableView.dequeueReusableCell(for: indexPath) as ForumNameSecondaryTableViewCell)
            case .secondaryLast:
                cell = (tableView.dequeueReusableCell(for: indexPath) as ForumNameSecondaryLastTableViewCell)
            }
            cell.forumName = item.forumName
            cell.accessoryType = item.isChoosed ? .checkmark : .none
            cell.detailDisclosureButton.isHidden = item.forumDescription == nil
            cell.detailDisclosureButton.rx.tap.asObservable()
                .subscribe(onNext: { _ in
                    let alert = UIAlertController(title: "版块介绍", message: item.forumDescription, preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                    alert.addAction(confirmAction)
                    self.present(alert, animated: true, completion: nil)
                }).addDisposableTo(cell.disposeBagCell)
            
            return cell
        }
    }
}
