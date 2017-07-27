//
//  Settings.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/24.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import SAMKeychain
import Argo
import Runes
import Curry
import RxSwift
import RxCocoa

/// 用于从Keychain中获取密码的服务名
private let kAccountServiceKey = "HiPDA-account"

/// 消息免打扰时间
typealias PmDoNotDisturbTime = (hour: Int, minute: Int)

/// 设置中心
class Settings {
    enum ConstantKeys {
        static let accountList = "accountList"
        static let lastLoggedInAccount = "lastLoggedInAccount"
        static let shouldAutoLogin = "shouldAutoLogin"
        static let activeAccount = "activeAccount"
        static let autoDownloadImageWhenUsingWWAN = "autoDownloadImageWhenUsingWWAN"
        static let autoDownloadImageSizeThreshold = "autoDownloadImageSizeThreshold"
        static let fontSize = "fontSize"
        static let lineSpacing = "lineSpacing"
        static let isEnabledUserBlock = "isEnabledUserBlock"
        static let userBlockList = "userBlockList"
        static let isEnabledThreadBlock = "isEnabledThreadBlock"
        static let threadBlockWordList = "threadBlockWordList"
        static let threadHistoryCountLimit = "threadHistoryCountLimit"
        static let isEnabledMessagePush = "isEnabledMessagePush"
        static let isEnabledSystemPm = "isEnabledSystemPm"
        static let isEnabledFriendPm = "isEnabledFriendPm"
        static let isEnabledThreadPm = "isEnabledThreadPm"
        static let isEnabledPrivatePm = "isEnabledPrivatePm"
        static let isEnabledAnnoucePm = "isEnabledAnnoucePm"
        static let isEnabledPmDoNotDisturb = "isEnabledPmDoNotDisturb"
        static let pmDoNotDisturbFromTime = "pmDoNotDisturbFromTime"
        static let pmDoNotDisturbToTime = "pmDoNotDisturbToTime"
        static let activeForumNameList = "activeForumNameList"
        static let isEnabledUserRemark = "isEnabledUserRemark"
        static let userRemarkDictionary = "userRemarkDictionary"
        static let isEnabledTail = "isEnabledTail"
        static let tailText = "tailText"
        static let tailURL = "tailURL"
        static let avatarImageResolution = "avatarImageResolution"
        static let autoLoadImageViaWWAN = "autoLoadImageViaWWAN"
    }
    
    static let shared = Settings()
    
    /// 可用账户列表
    var accountList: [Account]
    
    /// 上次登录账户
    var lastLoggedInAccount: Account?
    
    var shouldAutoLogin: Bool
    
    /// 当前登录账户
    var activeAccount: Account?
    
    /// 添加账户
    /// 因为可能用户更新了账户资料，根据uid来判断用户而不用等于
    ///
    /// - parameter account: 帐户
    ///
    /// - returns: 返回添加好帐户所在帐户列表中的下标
    @discardableResult
    func add(account: Account) -> Int {
        for (index, accountElement) in accountList.enumerated() {
            if accountElement.uid == account.uid {
                accountList.remove(at: index)
                accountList.insert(account, at: index)
                return index
            }
        }
        
        accountList.append(account)
        return accountList.endIndex - 1
    }
    
    /// 用手机流量模式下自动下载图片
    var autoDownloadImageWhenUsingWWAN: Bool
    
    /// WWAN自动下载图片阈值，单位byte，默认256kb
    var autoDownloadImageSizeThreshold: Int
    
    /// 读帖子界面字体大小
    var fontSize: Int
    
    /// 读帖子界面字体行间距
    var lineSpacing: Int
    
    /// 是否开启黑名单过滤
    var isEnabledUserBlock: Bool
    
    /// 黑名单列表，屏蔽用户名
    var userBlockList: [String]
    
    /// 是否开启帖子过滤
    var isEnabledThreadBlock: Bool
    
    /// 帖子过滤单词列表
    var threadBlockWordList: [String]
    
    /// 浏览历史的条数
    var threadHistoryCountLimit: Int
    private static let kThreadHistoryCountDefault = 100
    
    /// 是否开启消息推送
    var isEnabledMessagePush: Bool
    
    /// 是否开启系统消息推送
    var isEnabledSystemPm: Bool
    
    /// 是否开启好友消息推送
    var isEnabledFriendPm: Bool
    
    /// 是否开启帖子消息推送
    var isEnabledThreadPm: Bool
    
    /// 是否开启私人消息推送
    var isEnabledPrivatePm: Bool
    
    /// 是否开启公共消息推送
    var isEnabledAnnoucePm: Bool
    
    /// 是否开启消息免打扰
    var isEnabledPmDoNotDisturb: Bool
    
    /// 免打扰的开始时间
    var pmDoNotDisturbFromTime: PmDoNotDisturbTime
    
    /// 免打扰的结束时间
    var pmDoNotDisturbToTime: PmDoNotDisturbTime
    
    /// 板块列表
    var activeForumNameList: [String]
    
    /// 是否开启用户备注
    var isEnabledUserRemark: Bool
    
    /// 用户备注字典，键为用户uid
    var userRemarkDictionary: [String: String]
    
    /// 是否开启小尾巴设置
    var isEnabledTail: Bool
    
    /// 小尾巴文字
    var tailText: String
    
    /// 小尾巴链接
    var tailURL: URL?
    
    /// 用户头像的分辨率
    var avatarImageResolution: UserAvatarImageResolution
    
    var autoLoadImageViaWWAN: Bool
    
    init() {
        typealias `Self` = Settings
        func boolValue(in userDefaults: UserDefaults, key: String, defalut: Bool) -> Bool {
            return (userDefaults.value(forKey: key) as? Bool) ?? defalut
        }
        
        let userDefaults = UserDefaults.standard
        let accountNameArray = (userDefaults.value(forKey: ConstantKeys.accountList) as? [String]) ?? []
        
        func account(with name: String) -> Account? {
            let accountString = SAMKeychain.password(forService: kAccountServiceKey, account: name) ?? ""
            let accountData = accountString.data(using: .utf8) ?? Data()
            guard let attributes = try? JSONSerialization.jsonObject(with: accountData, options: []) else { return nil }
            return try? Account.decode(JSON(attributes)).dematerialize()
        }
        accountList = accountNameArray.flatMap(account(with:))
        lastLoggedInAccount = (userDefaults.value(forKey: ConstantKeys.lastLoggedInAccount) as? String).flatMap(account(with:))
        shouldAutoLogin = boolValue(in: userDefaults, key: ConstantKeys.shouldAutoLogin, defalut: true)
        
        autoDownloadImageWhenUsingWWAN = boolValue(in: userDefaults, key: ConstantKeys.autoDownloadImageWhenUsingWWAN, defalut: true)
        autoDownloadImageSizeThreshold = (userDefaults.value(forKey: ConstantKeys.autoDownloadImageSizeThreshold) as? Int) ?? 256 * 1024
        fontSize = (userDefaults.value(forKey: ConstantKeys.fontSize) as? Int) ?? 17
        lineSpacing = (userDefaults.value(forKey: ConstantKeys.lineSpacing) as? Int) ?? 1
        isEnabledUserBlock = boolValue(in: userDefaults, key: ConstantKeys.isEnabledUserBlock, defalut: true)
        userBlockList = (userDefaults.value(forKey: ConstantKeys.userBlockList) as? [String]) ?? []
        isEnabledThreadBlock = boolValue(in: userDefaults, key: ConstantKeys.isEnabledThreadBlock, defalut: false)
        threadBlockWordList = (userDefaults.value(forKey: ConstantKeys.threadBlockWordList) as? [String]) ?? []
        threadHistoryCountLimit = (userDefaults.value(forKey: ConstantKeys.threadHistoryCountLimit) as? Int) ?? Self.kThreadHistoryCountDefault
        isEnabledMessagePush = boolValue(in: userDefaults, key: ConstantKeys.isEnabledMessagePush, defalut: true)
        isEnabledSystemPm = boolValue(in: userDefaults, key: ConstantKeys.isEnabledSystemPm, defalut: true)
        isEnabledFriendPm = boolValue(in: userDefaults, key: ConstantKeys.isEnabledFriendPm, defalut: true)
        isEnabledThreadPm = boolValue(in: userDefaults, key: ConstantKeys.isEnabledThreadPm, defalut: true)
        isEnabledPrivatePm = boolValue(in: userDefaults, key: ConstantKeys.isEnabledPrivatePm, defalut: true)
        isEnabledAnnoucePm = boolValue(in: userDefaults, key: ConstantKeys.isEnabledAnnoucePm, defalut: true)
        isEnabledPmDoNotDisturb = boolValue(in: userDefaults, key: ConstantKeys.isEnabledPmDoNotDisturb, defalut: true)
        if let dictionary = userDefaults.value(forKey: ConstantKeys.pmDoNotDisturbFromTime) as? [String: Int],
            let hour = dictionary["hour"], let minute = dictionary["minute"] {
            pmDoNotDisturbFromTime = (hour: hour, minute: minute)
        } else {
            pmDoNotDisturbFromTime = (hour: 22, minute: 0)
        }
        if let dictionary = userDefaults.value(forKey: ConstantKeys.pmDoNotDisturbToTime) as? [String: Int],
            let hour = dictionary["hour"], let minute = dictionary["minute"] {
            pmDoNotDisturbToTime = (hour: hour, minute: minute)
        } else {
            pmDoNotDisturbToTime = (hour: 9, minute: 0)
        }
        activeForumNameList = (userDefaults.value(forKey: ConstantKeys.activeForumNameList) as? [String]) ?? ForumManager.defalutForumNameList
        isEnabledUserRemark = boolValue(in: userDefaults, key: ConstantKeys.isEnabledUserRemark, defalut: false)
        userRemarkDictionary = (userDefaults.value(forKey: ConstantKeys.userRemarkDictionary) as? [String: String]) ?? [:]
        isEnabledTail = boolValue(in: userDefaults, key: ConstantKeys.isEnabledTail, defalut: true)
        tailText = (userDefaults.value(forKey: ConstantKeys.tailText) as? String) ?? "小尾巴~"
        if boolValue(in: userDefaults, key: "kFirstLaunch", defalut: true) {
            tailURL = URL(string: "https://www.hi-pda.com/forum/viewthread.php?tid=2137250&extra=&page=1")
            userDefaults.set(false, forKey: "kFirstLaunch")
        } else {
            if let urlString = userDefaults.value(forKey: ConstantKeys.tailURL) as? String {
                tailURL = URL(string: urlString)
            }
        }
        avatarImageResolution = UserAvatarImageResolution(rawValue: userDefaults.string(forKey: ConstantKeys.avatarImageResolution) ?? "middle") ?? .middle
        autoLoadImageViaWWAN = boolValue(in: userDefaults, key: ConstantKeys.autoLoadImageViaWWAN, defalut: true)
    }
    
    /// 持久化
    func save() {
        typealias `Self` = Settings
        
        let userDefaults = UserDefaults.standard
        let accountNameArray = accountList.map { $0.name }
        if accountNameArray.count == 0 {
            userDefaults.removeObject(forKey: ConstantKeys.accountList)
        } else {
            userDefaults.setValue(accountNameArray, forKey: ConstantKeys.accountList)
            accountList.forEach { account in
                SAMKeychain.setPassword(account.encode(), forService: kAccountServiceKey, account: account.name)
            }
        }
        if let account = lastLoggedInAccount {
            userDefaults.setValue(account.name, forKey: ConstantKeys.lastLoggedInAccount)
        } else {
            userDefaults.removeObject(forKey: ConstantKeys.lastLoggedInAccount)
        }
        userDefaults.set(shouldAutoLogin, forKey: ConstantKeys.shouldAutoLogin)
        userDefaults.set(autoDownloadImageWhenUsingWWAN, forKey: ConstantKeys.autoDownloadImageWhenUsingWWAN)
        userDefaults.set(autoDownloadImageSizeThreshold, forKey: ConstantKeys.autoDownloadImageSizeThreshold)
        userDefaults.set(fontSize, forKey: ConstantKeys.fontSize)
        userDefaults.set(lineSpacing, forKey: ConstantKeys.lineSpacing)
        userDefaults.set(isEnabledUserBlock, forKey: ConstantKeys.isEnabledUserBlock)
        userDefaults.set(userBlockList, forKey: ConstantKeys.userBlockList)
        userDefaults.set(isEnabledThreadBlock, forKey: ConstantKeys.isEnabledThreadBlock)
        userDefaults.set(threadBlockWordList, forKey: ConstantKeys.threadBlockWordList)
        userDefaults.set(threadHistoryCountLimit, forKey: ConstantKeys.threadHistoryCountLimit)
        userDefaults.set(isEnabledMessagePush, forKey: ConstantKeys.isEnabledMessagePush)
        userDefaults.set(isEnabledSystemPm, forKey: ConstantKeys.isEnabledSystemPm)
        userDefaults.set(isEnabledFriendPm, forKey: ConstantKeys.isEnabledFriendPm)
        userDefaults.set(isEnabledThreadPm, forKey: ConstantKeys.isEnabledThreadPm)
        userDefaults.set(isEnabledPrivatePm, forKey: ConstantKeys.isEnabledPrivatePm)
        userDefaults.set(isEnabledAnnoucePm, forKey: ConstantKeys.isEnabledAnnoucePm)
        userDefaults.set(isEnabledPmDoNotDisturb, forKey: ConstantKeys.isEnabledPmDoNotDisturb)
        let fromTimeDictionary = [
            "hour": pmDoNotDisturbFromTime.hour,
            "minute": pmDoNotDisturbFromTime.minute
        ]
        userDefaults.set(fromTimeDictionary, forKey: ConstantKeys.pmDoNotDisturbFromTime)
        let toTimeDictionary = [
            "hour": pmDoNotDisturbToTime.hour,
            "minute": pmDoNotDisturbToTime.minute
        ]
        userDefaults.set(toTimeDictionary, forKey: ConstantKeys.pmDoNotDisturbToTime)
        userDefaults.set(activeForumNameList, forKey: ConstantKeys.activeForumNameList)
        userDefaults.set(isEnabledUserRemark, forKey: ConstantKeys.isEnabledUserRemark)
        userDefaults.set(userRemarkDictionary, forKey: ConstantKeys.userRemarkDictionary)
        userDefaults.set(isEnabledTail, forKey: ConstantKeys.isEnabledTail)
        userDefaults.set(tailText, forKey: ConstantKeys.tailText)
        if let url = tailURL {
            let urlString = url.absoluteString
            userDefaults.set(urlString, forKey: ConstantKeys.tailURL)
        } else {
            userDefaults.removeObject(forKey: ConstantKeys.tailURL)
        }
        userDefaults.set(avatarImageResolution.rawValue, forKey: ConstantKeys.avatarImageResolution)
        userDefaults.set(autoLoadImageViaWWAN, forKey: ConstantKeys.autoLoadImageViaWWAN)
        userDefaults.synchronize()
    }
    
    /// 恢复到默认设置,测试用
    func reset() {
        /// 清楚所有缓存
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys where key != ConstantKeys.accountList && key != ConstantKeys.activeAccount {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        
        /// 设置默认值
        shouldAutoLogin = true
        autoDownloadImageWhenUsingWWAN = true
        autoDownloadImageSizeThreshold = 256 * 1024
        fontSize = 17
        lineSpacing = 1
        isEnabledUserBlock = true
        userBlockList = []
        isEnabledThreadBlock = false
        threadBlockWordList = []
        threadHistoryCountLimit = Settings.kThreadHistoryCountDefault
        isEnabledMessagePush = true
        isEnabledSystemPm = true
        isEnabledFriendPm = true
        isEnabledThreadPm = true
        isEnabledPrivatePm = true
        isEnabledAnnoucePm = true
        isEnabledPmDoNotDisturb = true
        pmDoNotDisturbFromTime = (hour: 22, minute: 0)
        pmDoNotDisturbToTime = (hour: 9, minute: 0)
        activeForumNameList = ForumManager.defalutForumNameList
        isEnabledUserRemark = false
        userRemarkDictionary = [:]
        isEnabledTail = true
        tailText = "小尾巴~"
        tailURL = URL(string: "https://www.hi-pda.com/forum/viewthread.php?tid=2137250&extra=&page=1")
        avatarImageResolution = .middle
        autoLoadImageViaWWAN = true
    }
}

// MARK: - Settings的Rx扩展

extension Settings: ReactiveCompatible { }

extension Reactive where Base: Settings {
    /// 状态
    var activeAccount: UIBindingObserver<Base, LoginResult?> {
        return UIBindingObserver(UIElement: base) { (settings, loginResult) in
            if let loginResult = loginResult, case let .success(account) = loginResult {
                settings.activeAccount = account
                settings.lastLoggedInAccount = account
                settings.save()
            } else {
                settings.activeAccount = nil
            }
        }
    }
}
