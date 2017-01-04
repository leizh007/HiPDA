//
//  SettingsViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/2.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa

/// 设置
class SettingsViewController: UITableViewController {
    /// disposeBag
    private let disposeBag = DisposeBag()
    
    /// 设置
    private let settings = Settings.shared
    
    /// viewModel
    var viewModel: SettingsViewModel!
    
    /// 用户头像
    @IBOutlet private weak var avatarImageView: UIImageView!
    
    /// 用户黑名单
    @IBOutlet private weak var userBlockSwitch: UISwitch!
    
    /// 帖子过滤
    @IBOutlet private weak var threadBlockSwitch: UISwitch!
    
    /// 帖子关注
    @IBOutlet private weak var threadAttentionSwitch: UISwitch!
    
    /// 消息推送
    @IBOutlet private weak var messagePushSwitch: UISwitch!
    
    /// 系统消息
    @IBOutlet private weak var systemPmSwitch: UISwitch!
    
    /// 好友消息
    @IBOutlet private weak var friendPmSwitch: UISwitch!
    
    /// 帖子消息
    @IBOutlet private weak var threadPmSwitch: UISwitch!
    
    /// 私人消息
    @IBOutlet private weak var privatePmSwitch: UISwitch!
    
    /// 公共消息
    @IBOutlet private weak var annoucePmSwitch: UISwitch!
    
    /// 消息免打扰
    @IBOutlet private weak var pmDoNotDisturbSwitch: UISwitch!
    
    /// 消息免打扰描述label
    @IBOutlet private weak var pmDoNotDisturbDescriptionLabel: UILabel!
    
    /// 是否展示置顶贴
    @IBOutlet private weak var isShowStickThreadsSwitch: UISwitch!
    
    /// 用户备注
    @IBOutlet private weak var userRemarkSwitch: UISwitch!
    
    /// 小尾巴
    @IBOutlet private weak var tailSwitch: UISwitch!
    
    /// 浏览历史条数
    @IBOutlet private weak var historyCountLimitTextField: UITextField!
    
    /// 小尾巴文字
    @IBOutlet private weak var tailTextTextField: UITextField!
    
    /// 小尾巴链接
    @IBOutlet private weak var tailURLTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        
        configureViewModel()
        configureTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        settings.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// 配置viewModel
    private func configureViewModel() {
        viewModel = SettingsViewModel(settings: self.settings)
        userBlockSwitch.isOn = viewModel.isEnabledUserBlock
        threadBlockSwitch.isOn = viewModel.isEnabledThreadBlock
        threadAttentionSwitch.isOn = viewModel.isEnabledThreadAttention
        messagePushSwitch.isOn = viewModel.isEnabledMessagePush
        systemPmSwitch.isOn = viewModel.isEnabledSystemPm
        friendPmSwitch.isOn = viewModel.isEnabledFriendPm
        threadPmSwitch.isOn = viewModel.isEnabledThreadPm
        privatePmSwitch.isOn = viewModel.isEnabledPrivatePm
        annoucePmSwitch.isOn = viewModel.isEnabledAnnoucePm
        pmDoNotDisturbSwitch.isOn = viewModel.isEnabledPmDoNotDisturb
        userBlockSwitch.isOn = viewModel.isEnabledUserBlock
        userRemarkSwitch.isOn = viewModel.isEnabledUserRemark
        tailSwitch.isOn = viewModel.isEnabledTail
        historyCountLimitTextField.text = viewModel.threadHistoryCountLimitString
        tailTextTextField.text = viewModel.tailText
        tailURLTextField.text = viewModel.tailURLString
        isShowStickThreadsSwitch.isOn = viewModel.isShowStickThreads
        
        viewModel.pmDoNotDisturbDescription.asObservable()
            .bindTo(pmDoNotDisturbDescriptionLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        let historyCountLimit = historyCountLimitTextField.rx.controlEvent(.editingDidEnd)
            .map { [weak textField = historyCountLimitTextField] in
                return textField?.text ?? ""
            }.asDriver(onErrorJustReturn: "")
        let tailText = tailTextTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .map { [weak textField = tailTextTextField] in
                textField?.resignFirstResponder()
                return textField?.text ?? ""
            }.asDriver(onErrorJustReturn: "")
        let tailURL = tailURLTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .map { [weak textField = tailURLTextField] in
                textField?.resignFirstResponder()
                return textField?.text ?? ""
            }.asDriver(onErrorJustReturn: "")
        
        viewModel.handle(userBlock: userBlockSwitch.rx.value.asDriver(),
                         threadBlock: threadBlockSwitch.rx.value.asDriver(),
                         threadAttention: threadAttentionSwitch.rx.value.asDriver(),
                         messagePush: messagePushSwitch.rx.value.asDriver(),
                         systemPm: systemPmSwitch.rx.value.asDriver(),
                         friendPm: friendPmSwitch.rx.value.asDriver(),
                         threadPm: threadPmSwitch.rx.value.asDriver(),
                         privatePm: privatePmSwitch.rx.value.asDriver(),
                         announcePm: annoucePmSwitch.rx.value.asDriver(),
                         pmDoNotDisturb: pmDoNotDisturbSwitch.rx.value.asDriver(),
                         isShowStickThreads: isShowStickThreadsSwitch.rx.value.asDriver(),
                         userRemark: userRemarkSwitch.rx.value.asDriver(),
                         historyCountLimit: historyCountLimit,
                         tail: tailSwitch.rx.value.asDriver(),
                         tailText: tailText,
                         tailURL: tailURL)
    }
    
    /// 配置tableView相关
    private func configureTableView() {
        let router = SettingsRouter(viewController: self)
        
        tableView.rx.delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            }).addDisposableTo(disposeBag)
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.view.endEditing(true)
                router.handleSelection(for: indexPath)
            }).addDisposableTo(disposeBag)
    }
}
