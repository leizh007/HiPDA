//
//  EditWordListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/9.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

/// 编辑单词数组完后的回调block
typealias EditWordListCompletion = ([String]) -> ()

/// 编辑单词列表的viewController
class EditWordListViewController: BaseViewController {
    /// 单词列表
    var words = [String]() {
        didSet {
            replaceCommand.onNext(.replace(EditWordListTableViewState(sections:[EditWordListSection(words:words)])))
            tableView.status = words.count == 0 ? .noResult : .normal
        }
    }
    
    /// 编辑完后的回调block
    var completion: EditWordListCompletion?
    
    /// tableView
    fileprivate let tableView = BaseTableView(frame: .zero, style: .grouped).then { tableView in
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height:CGFloat.leastNormalMagnitude))
    }
    
    /// tableView是否处在编辑状态
    fileprivate let isTableViewEditing = Variable(false)
    
    /// 添加
    fileprivate let appendCommand = PublishSubject<EditWordListTableViewEditingCommand>()
    
    /// manually delete from custom tableView cell action
    fileprivate let deleteCommandManually = PublishSubject<EditWordListTableViewEditingCommand>()
    
    /// 替换command
    fileprivate let replaceCommand = PublishSubject<EditWordListTableViewEditingCommand>()
    
    /// 将要dismiss
    fileprivate let willDismiss = Variable(false)
    
    /// 添加按钮
    fileprivate lazy var addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    /// 完成按钮
    fileprivate lazy var doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureAddBarButtonItem()
        configureDoneBarButtonItem()
        
        isTableViewEditing.asDriver().drive(onNext: { [unowned self] isEditing in
            self.navigationItem.rightBarButtonItem = isEditing ? self.doneBarButtonItem : self.addBarButtonItem
            self.tableView.setEditing(isEditing, animated: true)
        }).addDisposableTo(disposeBag)
    }    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        // 回到上级页面的时候
        guard parent == nil else { return }
        willDismiss.value = true
    }
}

// MAARK: - Configurations

extension EditWordListViewController {
    /// 设置tableView
    fileprivate func configureTableView() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self)
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<EditWordListSection>()
        skinTableViewDataSource(dataSource)
        
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(EditWordListTableViewEditingCommand.delete)
        let moveCommand = tableView.rx.itemMoved.asObservable()
            .map(EditWordListTableViewEditingCommand.move)
        let initialState = EditWordListTableViewState(sections: [EditWordListSection(words: words)])
        let data = Observable.of(replaceCommand, appendCommand, deleteCommand, deleteCommandManually, moveCommand)
            .merge()
            .scan(initialState) {
                return $0.execute($1)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .shareReplay(1)
        data.bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        data.map { sections in
            return sections.reduce(0) {
                return $0 + $1.items.count
            } == 0 ? .noResult : .normal
        }.bindTo(tableView.rx.status).addDisposableTo(disposeBag)
        
        willDismiss.asObservable()
            .filter { $0 }
            .withLatestFrom(data)
            .subscribe(onNext: { [unowned self] section in
                self.completion?(section[0].items)
            }).addDisposableTo(disposeBag)
    }
    
    /// 设置tableView的数据源
    ///
    /// - Parameter dataSource: 数据源
    fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedAnimatedDataSource<EditWordListSection>) {
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left)
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            return (tableView.dequeueReusableCell(for: indexPath) as UITableViewCell).then {
                $0.textLabel?.text = "\(item)"
            }
        }
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }
    }
    
    /// 设置完成按钮
    fileprivate func configureDoneBarButtonItem() {
        doneBarButtonItem.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.isTableViewEditing.value = false
        }).addDisposableTo(disposeBag)
    }
    
    /// 设置添加按钮
    fileprivate func configureAddBarButtonItem() {
        addBarButtonItem.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.tableView.setEditing(false, animated: true)
            let alert = UIAlertController(title: "添加", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "请输入单词"
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "确定", style: .default) { [unowned self, unowned alert] _ in
                guard let textField = alert.textFields?.safe[0], let text = textField.text, !text.isEmpty else { return }
                self.appendCommand.onNext(.append(text, in: 0))
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension EditWordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sortAction = UITableViewRowAction(style: .normal, title: "编辑") { [unowned self] (action, indexPath) in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.isTableViewEditing.value = true
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除") { [unowned self] (action, indexPath) in
            self.deleteCommandManually.onNext(.delete(with: indexPath))
        }
        
        return [deleteAction, sortAction]
    }
}
