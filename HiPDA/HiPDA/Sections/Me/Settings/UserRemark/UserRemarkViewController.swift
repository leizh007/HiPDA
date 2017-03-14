//
//  UserRemarkViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Then

/// 用户备注修改完后的回调block
typealias UserRemarkCompletionHandler = ([String: String]) -> Void

/// 用户备注的ViewController
class UserRemarkViewController: BaseViewController {
    /// 用户备注字典
    var userRemarkDictionary = [String: String]() {
        didSet {
            let attributes = userRemarkDictionary.map(UserRemark.init)
            replaceCommand.onNext(.replace(UserRemarkTableViewState(sections: [UserRemarkSection(header: "0",attributes: attributes)])))
        }
    }
    
    /// 处理完后的回调block
    var complation: UserRemarkCompletionHandler?
    
    /// tableView
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    /// section的header试图
    @IBOutlet fileprivate var sectionHeaderView: UIView!
    
    /// 处理完将要退回上层界面
    fileprivate let willDismiss = Variable(false)
    
    /// 替换指令
    fileprivate let replaceCommand = PublishSubject<UserRemarkTableViewEditingCommand>()
    
    /// 增加指令
    fileprivate let appendCommand = PublishSubject<UserRemarkTableViewEditingCommand>()
    
    /// 用户上次输入的用户名
    fileprivate var lastUserInputUserName = ""
    
    /// 用户上次输入的备注名
    fileprivate var lastUserInputRemarkName = ""
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        // 回到上级页面的时候
        guard parent == nil else { return }
        willDismiss.value = true
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        let showAddUserRemarkAlert = PublishSubject<Void>()
        let showWarningAlert = PublishSubject<Void>()
        
        Observable.of(addBarButtonItem.rx.tap.asObservable(), showAddUserRemarkAlert)
            .merge()
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.setEditing(false, animated: true)
                let alert = UIAlertController(title: "添加", message: nil, preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.text = self.lastUserInputUserName
                    textField.placeholder = "请输入用户名"
                })
                alert.addTextField(configurationHandler: { (textField) in
                    textField.text = self.lastUserInputRemarkName
                    textField.placeholder = "请输入用户的备注名"
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { [unowned self] _ in
                    self.lastUserInputRemarkName = ""
                    self.lastUserInputUserName = ""
                })
                let confirmAction = UIAlertAction(title: "添加", style: .default, handler: { [unowned alert] _ in
                    guard let textField0 = alert.textFields?.safe[0], let textField1 = alert.textFields?.safe[1] else { return }
                    self.lastUserInputUserName = textField0.text ?? ""
                    self.lastUserInputRemarkName = textField1.text ?? ""
                    if !self.lastUserInputRemarkName.isEmpty && !self.lastUserInputUserName.isEmpty {
                        self.appendCommand.onNext(.append(UserRemark(userName: self.lastUserInputUserName, remarkName: self.lastUserInputRemarkName), in: 0))
                        self.lastUserInputUserName = ""
                        self.lastUserInputRemarkName = ""
                    } else {
                        showWarningAlert.onNext(())
                    }
                })
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
            }).addDisposableTo(disposeBag)
        
        showWarningAlert.subscribe(onNext: { [unowned self] _ in
            let warningAlert = UIAlertController(title: "输入不正确", message: "输入用户名或者备注为空，重新输入？", preferredStyle: .alert)
            let warningAlertCancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                self.lastUserInputUserName = ""
                self.lastUserInputRemarkName = ""
            })
            let warningAlertConfirmAction = UIAlertAction(title: "确定", style: .default, handler: { _ in
                showAddUserRemarkAlert.onNext(())
            })
            warningAlert.addAction(warningAlertCancelAction)
            warningAlert.addAction(warningAlertConfirmAction)
            self.present(warningAlert, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}

// MARK: - Configurations

extension UserRemarkViewController {
    /// 配置tableView
    fileprivate func configureTableView() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height:CGFloat.leastNormalMagnitude))
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).addDisposableTo(disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<UserRemarkSection>()
        skinTableViewDataSource(dataSource)
        
        let deleteCommand = tableView.rx.itemDeleted
            .map(UserRemarkTableViewEditingCommand.delete)
        let attributes = userRemarkDictionary.map(UserRemark.init)
        let initialState = UserRemarkTableViewState(sections: [UserRemarkSection(header: "0",attributes: attributes)])
        let data = Observable.of(replaceCommand, appendCommand, deleteCommand)
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
        data.map { sections in
                return sections.reduce(0) {
                    $0 + $1.items.count
                }
            }.do(onNext: { [unowned self] count in
                self.sectionHeaderView.isHidden = count == 0
            })
            .map {
                $0 == 0 ? .noResult : .normal
            }
            .bindTo(tableView.rx.status)
            .addDisposableTo(disposeBag)
        
        willDismiss.asObservable()
            .filter { $0 }
            .withLatestFrom(data)
            .map { sections in
                return sections[0].attributes.reduce([String: String]()) { (dictionary, userRemark) in
                    var dic = dictionary
                    dic[userRemark.userName] = userRemark.remarkName
                    return dic
                }
            }.subscribe(onNext: { [unowned self] dictionary in
                self.complation?(dictionary)
            }).addDisposableTo(disposeBag)
    }
    
    /// 设置tableView的数据源
    ///
    /// - Parameter dataSource: 数据源
    fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedAnimatedDataSource<UserRemarkSection>) {
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left)
        dataSource.configureCell = { (_, tableView, indexPath, userRemark) in
            return (tableView.dequeueReusableCell(for: indexPath) as UserRemarkTableViewCell).then {
                $0.userRemark = userRemark
            }
        }
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
    }
}

// MARK: - UITableViewDelegate

extension UserRemarkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28.0
    }
}
