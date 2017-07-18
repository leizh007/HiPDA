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
    
    /// 清理缓存的cacheIndicatorView
    @IBOutlet private weak var cacheIndicatorView: UIActivityIndicatorView!
    
    /// 缓存大小
    @IBOutlet private weak var cacheSizeLabel: UILabel!
    
    /// 无线网络下自动下载图片的switch
    @IBOutlet private weak var autoLoadImageViaWWANSwitch: UISwitch!
    
    @IBOutlet private weak var threadOrderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        
        configureViewModel()
        configureTableView()
        configureClearCache()
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
        autoLoadImageViaWWANSwitch.isOn = viewModel.autoLoadImageViaWWAN
        threadOrderLabel.text = viewModel.threadOrder.descriptionForDisplay
        
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
                         tailURL: tailURL,
                         autoLoadImageViaWWANSwitch: autoLoadImageViaWWANSwitch.rx.value.asDriver())
    }
    
    /// 配置tableView相关
    private func configureTableView() {
        enum C {
            static let clearCacheIndexPath = IndexPath(row: 0, section: 11)
            static let threadOrderIndexPath = IndexPath(row: 0, section: 7)
        }
        
        let router = SettingsRouter(viewController: self)
        
        tableView.rx.delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            }).addDisposableTo(disposeBag)
        tableView.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { [unowned self] indexPath in
                switch indexPath {
                case C.clearCacheIndexPath:
                    self.showClearCacheExplaination()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.view.endEditing(true)
                switch indexPath {
                case C.clearCacheIndexPath:
                    self.clearCache()
                case C.threadOrderIndexPath:
                    self.showThreadOrderSelectionView()
                default:
                    router.handleSelection(for: indexPath)
                }
            }).addDisposableTo(disposeBag)
    }
    
    private func showThreadOrderSelectionView() {
        let orders = [HiPDA.ThreadOrder.heats,
                      HiPDA.ThreadOrder.dateline,
                      HiPDA.ThreadOrder.replies,
                      HiPDA.ThreadOrder.views,
                      HiPDA.ThreadOrder.lastpost]
        let orderDescriptions = orders.map { $0.descriptionForDisplay }
        let pickerActionSheetController = PickerActionSheetController.load(from: .views)
        pickerActionSheetController.pickerTitles = orderDescriptions
        pickerActionSheetController.initialSelelctionIndex = orders.index(of: viewModel.threadOrder)
        pickerActionSheetController.selectedCompletionHandler = { [unowned self] (index) in
            self.dismiss(animated: false, completion: nil)
            if let index = index, let order = orders.safe[index] {
                self.threadOrderLabel.text = order.descriptionForDisplay
                self.viewModel.threadOrder = order
            }
        }
        pickerActionSheetController.modalPresentationStyle = .overCurrentContext
        present(pickerActionSheetController, animated: false, completion: nil)
    }
    
    private func clearCache() {
        cacheIndicatorView.isHidden = false
        cacheIndicatorView.startAnimating()
        cacheSizeLabel.isHidden = true
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk(onCompletion: {
            DispatchQueue.global().async {
                // 缓存大小，Byte为单位
                let cacheSize = SettingsViewController.memorySizeDescription(of: SDImageCache.shared().getSize())
                DispatchQueue.main.async {
                    self.cacheIndicatorView.stopAnimating()
                    self.cacheIndicatorView.isHidden = true
                    self.cacheSizeLabel.isHidden = false
                    self.cacheSizeLabel.text = cacheSize
                }
            }
        })
    }
    
    private func configureClearCache() {
        cacheIndicatorView.isHidden = false
        cacheIndicatorView.startAnimating()
        cacheSizeLabel.text = "--"
        DispatchQueue.global().async {
            // 缓存大小，Byte为单位
            let cacheSize = SettingsViewController.memorySizeDescription(of: SDImageCache.shared().getSize())
            DispatchQueue.main.async {
                self.cacheIndicatorView.stopAnimating()
                self.cacheIndicatorView.isHidden = true
                self.cacheSizeLabel.text = cacheSize
            }
        }
    }
    
    fileprivate static func memorySizeDescription(of size: UInt) -> String {
        let size = Double(size)
        let sizeString: String
        if (size > pow(10, 9)) {
            // size >= 1GB
            sizeString = String(format: "%dGB", Int(size / pow(10, 9)))
        } else if (size > pow(10, 6)) {
            // size >= 1MB
            sizeString = String(format: "%dMB", Int(size / pow(10, 6)))
        } else if (size > pow(10, 3)) {
            // size >= 1KB
            sizeString = String(format: "%dKB", Int(size / pow(10, 3)))
        } else {
            sizeString = String(format: "%dB", Int(size))
        }
        
        return sizeString
    }
}

// MARK: - Show Explaination

extension SettingsViewController {
    fileprivate func showClearCacheExplaination() {
        let alert = UIAlertController(title: "说明", message: "只会清理图片缓存。\n浏览历史等缓存内容占空间小且不会动态增大，所以不会清理。", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
}
