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
    private var viewModel: SettingsViewModel!
    
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
    
    /// 用户备注
    @IBOutlet private weak var userRemarkSwitch: UISwitch!
    
    /// 小尾巴
    @IBOutlet private  weak var tailSwitch: UISwitch!
    
    /// 浏览历史条数
    @IBOutlet fileprivate weak var historyCountLimitTextField: UITextField!
    
    /// 小尾巴文字
    @IBOutlet fileprivate weak var tailTextTextField: UITextField!
    
    /// 小尾巴链接
    @IBOutlet fileprivate weak var tailURLTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = "设置"
        
        configureViews()
        configureViewModel()
        configureTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        settings.save()
    }
    
    /// 初始化配置view的值
    private func configureViews() {
        guard let account = settings.activeAccount else { return }
        avatarImageView.sd_setImage(with: account.avatarImageURL, placeholderImage: #imageLiteral(resourceName: "avatar_placeholder"))
        
        userBlockSwitch.isOn = settings.isEnabledUserBlock
        threadBlockSwitch.isOn = settings.isEnabledThreadBlock
        threadAttentionSwitch.isOn = settings.isEnabledThreadAttention
        messagePushSwitch.isOn = settings.isEnabledMessagePush
        systemPmSwitch.isOn = settings.isEnabledSystemPm
        friendPmSwitch.isOn = settings.isEnabledFriendPm
        threadPmSwitch.isOn = settings.isEnabledThreadPm
        privatePmSwitch.isOn = settings.isEnabledPrivatePm
        annoucePmSwitch.isOn = settings.isEnabledAnnoucePm
        pmDoNotDisturbSwitch.isOn = settings.isEnabledPmDoNotDisturb
        userBlockSwitch.isOn = settings.isEnabledUserBlock
        userRemarkSwitch.isOn = settings.isEnabledUserRemark
        tailSwitch.isOn = settings.isEnabledTail
        historyCountLimitTextField.text = "\(settings.threadHistoryCountLimit)"
        tailTextTextField.text = settings.tailText
        tailURLTextField.text = settings.tailURL?.absoluteString ?? ""
    }
    
    /// 配置viewModel
    private func configureViewModel() {
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
        
        viewModel = SettingsViewModel(settings: settings,
                                      userBlock: userBlockSwitch.rx.value.asDriver(),
                                      threadBlock: threadBlockSwitch.rx.value.asDriver(),
                                      threadAttention: threadAttentionSwitch.rx.value.asDriver(),
                                      messagePush: messagePushSwitch.rx.value.asDriver(),
                                      systemPm: systemPmSwitch.rx.value.asDriver(),
                                      friendPm: friendPmSwitch.rx.value.asDriver(),
                                      threadPm: threadPmSwitch.rx.value.asDriver(),
                                      privatePm: privatePmSwitch.rx.value.asDriver(),
                                      announcePm: annoucePmSwitch.rx.value.asDriver(),
                                      pmDoNotDisturb: pmDoNotDisturbSwitch.rx.value.asDriver(),
                                      userRemark: userRemarkSwitch.rx.value.asDriver(),
                                      historyCountLimit: historyCountLimit,
                                      tail: tailSwitch.rx.value.asDriver(),
                                      tailText: tailText,
                                      tailURL: tailURL)
    }
    
    /// 配置tableView相关
    private func configureTableView() {
        tableView.rx.delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            }).addDisposableTo(disposeBag)
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.view.endEditing(true)
            }).addDisposableTo(disposeBag)
    }
}
