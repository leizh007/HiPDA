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
    
    /// 是否开启帖子关注
    var isEnabledThreadAttention: Bool {
        return settings.isEnabledThreadAttention
    }
    
    /// 帖子关注单词列表
    var threadAttentionWordList: [String]{
        get {
            return settings.threadAttentionWordList
        }
        
        set {
            settings.threadAttentionWordList = newValue
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
    
    /// 是否开启用户备注
    var isEnabledUserRemark: Bool {
        return settings.isEnabledUserRemark
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
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    /// 处理事件
    func handle(userBlock: Driver<Bool>, threadBlock: Driver<Bool>, threadAttention: Driver<Bool>, messagePush: Driver<Bool>, systemPm: Driver<Bool>, friendPm: Driver<Bool>, threadPm: Driver<Bool>, privatePm: Driver<Bool>, announcePm: Driver<Bool>, pmDoNotDisturb: Driver<Bool>, userRemark: Driver<Bool>, historyCountLimit: Driver<String>, tail: Driver<Bool>, tailText: Driver<String>, tailURL: Driver<String>) {
        userBlock.drive(onNext: { on in
                self.settings.isEnabledUserBlock = on
            }).addDisposableTo(disposeBag)
        threadBlock.drive(onNext: { on in
            self.settings.isEnabledThreadBlock = on
        }).addDisposableTo(disposeBag)
        threadAttention.drive(onNext: { on in
            self.settings.isEnabledThreadAttention = on
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
    }
}
