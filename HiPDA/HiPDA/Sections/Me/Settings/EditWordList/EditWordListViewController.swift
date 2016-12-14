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

/// cell的identifier
private let kEditWordsCellIdentifier = "cell"

/// 编辑单词列表的viewController
class EditWordListViewController: BaseViewController {
    /// 单词列表
    var words = [String]() {
        didSet {
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
            if isEditing {
                self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
            } else {
                self.navigationItem.rightBarButtonItem = self.addBarButtonItem
            }
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
        guard parent == nil, let completion = self.completion else { return }
        completion(words)
    }
}

// MAARK: - Configurations

extension EditWordListViewController {
    /// 设置tableView
    fileprivate func configureTableView() {
        view.addSubview(tableView)
        tableView.status = words.count == 0 ? .noResult : .normal
        tableView.delegate = self
        tableView.dataSource = self
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
                self.words.append(text)
                let indexPath = IndexPath(row: self.words.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .right)
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension EditWordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var words = self.words
        let word = words[sourceIndexPath.row]
        words.remove(at: sourceIndexPath.row)
        words.insert(word, at: destinationIndexPath.row)
        self.words = words
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sortAction = UITableViewRowAction(style: .normal, title: "编辑") { [unowned self] (action, indexPath) in
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.isTableViewEditing.value = true
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除") { [unowned self] (action, indexPath) in
            self.words.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [deleteAction, sortAction]
    }
}

// MARK: - UITableViewDataSource

extension EditWordListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kEditWordsCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: kEditWordsCellIdentifier)
            cell?.selectionStyle = .none
        }
        cell?.textLabel?.text = words.safe[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
