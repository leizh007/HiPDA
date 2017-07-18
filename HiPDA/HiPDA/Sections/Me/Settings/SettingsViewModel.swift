//
//  SettingsViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/6.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 设置的ViewModel
struct SettingsViewModel {
    /// disposeBag
    private let disposeBag = DisposeBag()
    
    /// 设置
    private let settings: Settings
    
    /// 可用账户列表
    var accountList: [Account] {
        get {
            return settings.accountList
        }
        
        set {
            settings.accountList = newValue
        }
    }
    
    /// 当前登录账户
    var activeAccount: Account? {
        get {
            return settings.activeAccount
        }
        
        set {
            settings.activeAccount = newValue
        }
    }
    
    /// 是否开启黑名单过滤
    var isEnabledUserBlock: Bool {
        return settings.isEnabledUserBlock
    }
    
    /// 黑名单列表，屏蔽用户名
    var userBlockList: [String] {
        get {
            return settings.userBlockList
        }
        
        set {
            settings.userBlockList = newValue
        }
    }
    
    /// 是否开启帖子过滤
    var isEnabledThreadBlock: Bool {
        return settings.isEnabledThreadBlock
    }
    
    /// 帖子过滤单词列表
    var threadBlockWordList: [String]{
        get {
            return settings.threadBlockWordList
        }
        
        set {
            settings.threadBlockWordList = newValue
        }
    }
    
    /// 浏览历史的条数
    var threadHistoryCountLimitString: String {
        return "\(settings.threadHistoryCountLimit)"
    }
    
    /// 是否开启消息推送
    var isEnabledMessagePush: Bool {
        return settings.isEnabledMessagePush
    }
    
    /// 是否开启系统消息推送
    var isEnabledSystemPm: Bool {
        return settings.isEnabledSystemPm
    }
    
    /// 是否开启好友消息推送
    var isEnabledFriendPm: Bool {
        return settings.isEnabledFriendPm
    }
    
    /// 是否开启帖子消息推送
    var isEnabledThreadPm: Bool {
        return settings.isEnabledThreadPm
    }
    
    /// 是否开启私人消息推送
    var isEnabledPrivatePm: Bool {
        return settings.isEnabledPrivatePm
    }
    
    /// 是否开启公共消息推送
    var isEnabledAnnoucePm: Bool {
        return settings.isEnabledAnnoucePm
    }
    
    /// 是否开启消息免打扰
    var isEnabledPmDoNotDisturb: Bool {
        return settings.isEnabledPmDoNotDisturb
    }
    
    /// 消息免打扰描述字符串
    let pmDoNotDisturbDescription: Variable<String>
    
    /// 消息免打扰开始时间
    var pmDoNotDisturbFromTime: PmDoNotDisturbTime {
        get {
            return settings.pmDoNotDisturbFromTime
        }
        
        set {
            settings.pmDoNotDisturbFromTime = newValue
            pmDoNotDisturbDescription.value = SettingsViewModel.description(fromTime: settings.pmDoNotDisturbFromTime, toTime: settings.pmDoNotDisturbToTime)
        }
    }
    
    /// 消息免打扰结束时间
    var pmDoNotDisturbToTime: PmDoNotDisturbTime {
        get {
            return settings.pmDoNotDisturbToTime
        }
        
        set {
            settings.pmDoNotDisturbToTime = newValue
            pmDoNotDisturbDescription.value = SettingsViewModel.description(fromTime: settings.pmDoNotDisturbFromTime, toTime: settings.pmDoNotDisturbToTime)
        }
    }
    
    /// 是否开启用户备注
    var isEnabledUserRemark: Bool {
        return settings.isEnabledUserRemark
    }
    
    /// 用户备注字典
    var userRemarkDictionary: [String: String] {
        get {
            return settings.userRemarkDictionary
        }
        
        set {
            settings.userRemarkDictionary = newValue
        }
    }
    
    /// 板块列表
    var activeForumNameList: [String] {
        get {
            return settings.activeForumNameList
        }
        
        set {
            settings.activeForumNameList = newValue
        }
    }
    
    var threadOrder: HiPDA.ThreadOrder {
        get {
            return settings.threadOrder
        }
        
        set {
            settings.threadOrder = newValue
        }
    }
    
    /// 是否开启小尾巴设置
    var isEnabledTail: Bool {
        return settings.isEnabledTail
    }
    
    /// 小尾巴文字
    var tailText: String {
        return settings.tailText
    }
    
    /// 小尾巴链接
    var tailURLString: String {
        return settings.tailURL?.absoluteString ?? ""
    }
    
    var autoLoadImageViaWWAN: Bool {
        get {
            return settings.autoLoadImageViaWWAN
        }
        
        set {
            settings.autoLoadImageViaWWAN = newValue
        }
    }
    
    init(settings: Settings) {
        self.settings = settings
        pmDoNotDisturbDescription = Variable(SettingsViewModel.description(fromTime: settings.pmDoNotDisturbFromTime, toTime: settings.pmDoNotDisturbToTime))
    }
    
    /// 消息免打扰的描述字符串
    ///
    /// - Parameters:
    ///   - fromTime: 开始时间
    ///   - toTime: 结束时间
    /// - Returns: 描述字符串
    private static func description(fromTime: PmDoNotDisturbTime, toTime: PmDoNotDisturbTime) -> String {
        return String(format: "%d:%02d~%d:%02d", fromTime.hour, fromTime.minute, toTime.hour, toTime.minute)
    }
    
    /// 处理事件
    func handle(userBlock: Driver<Bool>, threadBlock: Driver<Bool>, messagePush: Driver<Bool>, systemPm: Driver<Bool>, friendPm: Driver<Bool>, threadPm: Driver<Bool>, privatePm: Driver<Bool>, announcePm: Driver<Bool>, pmDoNotDisturb: Driver<Bool>, userRemark: Driver<Bool>, historyCountLimit: Driver<String>, tail: Driver<Bool>, tailText: Driver<String>, tailURL: Driver<String>, autoLoadImageViaWWANSwitch: Driver<Bool>) {
        userBlock.drive(onNext: { on in
                self.settings.isEnabledUserBlock = on
            }).addDisposableTo(disposeBag)
        threadBlock.drive(onNext: { on in
            self.settings.isEnabledThreadBlock = on
        }).addDisposableTo(disposeBag)
        messagePush.drive(onNext: { on in
            self.settings.isEnabledMessagePush = on
        }).addDisposableTo(disposeBag)
        systemPm.drive(onNext: { on in
            self.settings.isEnabledSystemPm = on
        }).addDisposableTo(disposeBag)
        friendPm.drive(onNext: { on in
            self.settings.isEnabledFriendPm = on
        }).addDisposableTo(disposeBag)
        threadPm.drive(onNext: { on in
            self.settings.isEnabledThreadPm = on
        }).addDisposableTo(disposeBag)
        privatePm.drive(onNext: { on in
            self.settings.isEnabledPrivatePm = on
        }).addDisposableTo(disposeBag)
        announcePm.drive(onNext: { on in
            self.settings.isEnabledAnnoucePm = on
        }).addDisposableTo(disposeBag)
        pmDoNotDisturb.drive(onNext: { on in
            self.settings.isEnabledPmDoNotDisturb = on
        }).addDisposableTo(disposeBag)
        userRemark.drive(onNext: { on in
            self.settings.isEnabledUserRemark = on
        }).addDisposableTo(disposeBag)
        historyCountLimit.drive(onNext: { text in
            self.settings.threadHistoryCountLimit = Int(text) ?? 100
        }).addDisposableTo(disposeBag)
        tail.drive(onNext: { on in
            self.settings.isEnabledTail = on
        }).addDisposableTo(disposeBag)
        tailText.drive(onNext: { text in
            self.settings.tailText = text
        }).addDisposableTo(disposeBag)
        tailURL.drive(onNext: { text in
            self.settings.tailURL = URL(string: text)
        }).addDisposableTo(disposeBag)
        autoLoadImageViaWWANSwitch.drive(onNext: { on in
            self.settings.autoLoadImageViaWWAN = on
        }).addDisposableTo(disposeBag)
    }
}
