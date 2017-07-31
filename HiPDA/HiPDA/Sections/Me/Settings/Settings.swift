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
import YYCache

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
        static let useAvatarPlaceholder = "useAvatarPlaceholder"
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
    
    var useAvatarPlaceholder: Bool
    
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
        let storage = CacheManager.settings.shared!
        let accountNameArray = (storage.object(forKey: ConstantKeys.accountList) as? [String]) ?? []
        
        func boolValue(in storage: YYCache, key: String, defalut: Bool) -> Bool {
            return (storage.object(forKey: key) as? Bool) ?? defalut
        }

        func account(with name: String) -> Account? {
            let key = "\(kAccountServiceKey)\(name)"
            let accountString = storage.object(forKey: key) as? String ?? ""//SAMKeychain.password(forService: kAccountServiceKey, account: name) ?? ""
            let accountData = accountString.data(using: .utf8) ?? Data()
            guard let attributes = try? JSONSerialization.jsonObject(with: accountData, options: []) else { return nil }
            return try? Account.decode(JSON(attributes)).dematerialize()
        }
        accountList = accountNameArray.flatMap(account(with:))
        lastLoggedInAccount = (storage.object(forKey: ConstantKeys.lastLoggedInAccount) as? String).flatMap(account(with:))
        shouldAutoLogin = boolValue(in: storage, key: ConstantKeys.shouldAutoLogin, defalut: true)
        
        autoDownloadImageWhenUsingWWAN = boolValue(in: storage, key: ConstantKeys.autoDownloadImageWhenUsingWWAN, defalut: true)
        autoDownloadImageSizeThreshold = (storage.object(forKey: ConstantKeys.autoDownloadImageSizeThreshold) as? Int) ?? 256 * 1024
        useAvatarPlaceholder = boolValue(in: storage, key: ConstantKeys.useAvatarPlaceholder, defalut: true)
        fontSize = (storage.object(forKey: ConstantKeys.fontSize) as? Int) ?? 17
        lineSpacing = (storage.object(forKey: ConstantKeys.lineSpacing) as? Int) ?? 1
        isEnabledUserBlock = boolValue(in: storage, key: ConstantKeys.isEnabledUserBlock, defalut: true)
        userBlockList = (storage.object(forKey: ConstantKeys.userBlockList) as? [String]) ?? []
        isEnabledThreadBlock = boolValue(in: storage, key: ConstantKeys.isEnabledThreadBlock, defalut: false)
        threadBlockWordList = (storage.object(forKey: ConstantKeys.threadBlockWordList) as? [String]) ?? []
        threadHistoryCountLimit = (storage.object(forKey: ConstantKeys.threadHistoryCountLimit) as? Int) ?? Self.kThreadHistoryCountDefault
        isEnabledMessagePush = boolValue(in: storage, key: ConstantKeys.isEnabledMessagePush, defalut: true)
        isEnabledSystemPm = boolValue(in: storage, key: ConstantKeys.isEnabledSystemPm, defalut: true)
        isEnabledFriendPm = boolValue(in: storage, key: ConstantKeys.isEnabledFriendPm, defalut: true)
        isEnabledThreadPm = boolValue(in: storage, key: ConstantKeys.isEnabledThreadPm, defalut: true)
        isEnabledPrivatePm = boolValue(in: storage, key: ConstantKeys.isEnabledPrivatePm, defalut: true)
        isEnabledAnnoucePm = boolValue(in: storage, key: ConstantKeys.isEnabledAnnoucePm, defalut: true)
        isEnabledPmDoNotDisturb = boolValue(in: storage, key: ConstantKeys.isEnabledPmDoNotDisturb, defalut: true)
        if let dictionary = storage.object(forKey: ConstantKeys.pmDoNotDisturbFromTime) as? [String: Int],
            let hour = dictionary["hour"], let minute = dictionary["minute"] {
            pmDoNotDisturbFromTime = (hour: hour, minute: minute)
        } else {
            pmDoNotDisturbFromTime = (hour: 22, minute: 0)
        }
        if let dictionary = storage.object(forKey: ConstantKeys.pmDoNotDisturbToTime) as? [String: Int],
            let hour = dictionary["hour"], let minute = dictionary["minute"] {
            pmDoNotDisturbToTime = (hour: hour, minute: minute)
        } else {
            pmDoNotDisturbToTime = (hour: 9, minute: 0)
        }
        activeForumNameList = (storage.object(forKey: ConstantKeys.activeForumNameList) as? [String]) ?? ForumManager.defalutForumNameList
        isEnabledUserRemark = boolValue(in: storage, key: ConstantKeys.isEnabledUserRemark, defalut: false)
        userRemarkDictionary = (storage.object(forKey: ConstantKeys.userRemarkDictionary) as? [String: String]) ?? [:]
        isEnabledTail = boolValue(in: storage, key: ConstantKeys.isEnabledTail, defalut: true)
        tailText = (storage.object(forKey: ConstantKeys.tailText) as? String) ?? "小尾巴~"
        if boolValue(in: storage, key: "kFirstLaunch", defalut: true) {
            tailURL = URL(string: "https://www.hi-pda.com/forum/viewthread.php?tid=2137250&extra=&page=1")
            storage.setObject(false as NSNumber, forKey: "kFirstLaunch")
        } else {
            if let urlString = storage.object(forKey: ConstantKeys.tailURL) as? String {
                tailURL = URL(string: urlString)
            }
        }
        avatarImageResolution = UserAvatarImageResolution(rawValue: storage.object(forKey: ConstantKeys.avatarImageResolution) as? String ?? "middle") ?? .middle
        autoLoadImageViaWWAN = boolValue(in: storage, key: ConstantKeys.autoLoadImageViaWWAN, defalut: true)
    }
    
    /// 持久化
    func save() {
        typealias `Self` = Settings
        
        let storage = CacheManager.settings.shared!
        let accountNameArray = accountList.map { $0.name }
        if accountNameArray.count == 0 {
            storage.setObject(nil, forKey: ConstantKeys.accountList)
        } else {
            storage.setObject(accountNameArray as NSCoding, forKey: ConstantKeys.accountList)
            accountList.forEach { account in
                let key = "\(kAccountServiceKey)\(account.name)"
                storage.setObject(account.encode() as NSCoding, forKey: key)
//                SAMKeychain.setPassword(account.encode(), forService: kAccountServiceKey, account: account.name)
            }
        }
        if let account = lastLoggedInAccount {
            storage.setObject(account.name as NSCoding, forKey: ConstantKeys.lastLoggedInAccount)
        } else {
            storage.setObject(nil, forKey: ConstantKeys.lastLoggedInAccount)
        }
        storage.setObject(shouldAutoLogin as NSCoding, forKey: ConstantKeys.shouldAutoLogin)
        storage.setObject(autoDownloadImageWhenUsingWWAN as NSCoding, forKey: ConstantKeys.autoDownloadImageWhenUsingWWAN)
        storage.setObject(autoDownloadImageSizeThreshold as NSCoding, forKey: ConstantKeys.autoDownloadImageSizeThreshold)
        storage.setObject(useAvatarPlaceholder as NSCoding, forKey: ConstantKeys.useAvatarPlaceholder)
        storage.setObject(fontSize as NSCoding, forKey: ConstantKeys.fontSize)
        storage.setObject(lineSpacing as NSCoding, forKey: ConstantKeys.lineSpacing)
        storage.setObject(isEnabledUserBlock as NSCoding, forKey: ConstantKeys.isEnabledUserBlock)
        storage.setObject(userBlockList as NSCoding, forKey: ConstantKeys.userBlockList)
        storage.setObject(isEnabledThreadBlock as NSCoding, forKey: ConstantKeys.isEnabledThreadBlock)
        storage.setObject(threadBlockWordList as NSCoding, forKey: ConstantKeys.threadBlockWordList)
        storage.setObject(threadHistoryCountLimit as NSCoding, forKey: ConstantKeys.threadHistoryCountLimit)
        storage.setObject(isEnabledMessagePush as NSCoding, forKey: ConstantKeys.isEnabledMessagePush)
        storage.setObject(isEnabledSystemPm as NSCoding, forKey: ConstantKeys.isEnabledSystemPm)
        storage.setObject(isEnabledFriendPm as NSCoding, forKey: ConstantKeys.isEnabledFriendPm)
        storage.setObject(isEnabledThreadPm as NSCoding, forKey: ConstantKeys.isEnabledThreadPm)
        storage.setObject(isEnabledPrivatePm as NSCoding, forKey: ConstantKeys.isEnabledPrivatePm)
        storage.setObject(isEnabledAnnoucePm as NSCoding, forKey: ConstantKeys.isEnabledAnnoucePm)
        storage.setObject(isEnabledPmDoNotDisturb as NSCoding, forKey: ConstantKeys.isEnabledPmDoNotDisturb)
        let fromTimeDictionary = [
            "hour": pmDoNotDisturbFromTime.hour,
            "minute": pmDoNotDisturbFromTime.minute
        ]
        storage.setObject(fromTimeDictionary as NSCoding, forKey: ConstantKeys.pmDoNotDisturbFromTime)
        let toTimeDictionary = [
            "hour": pmDoNotDisturbToTime.hour,
            "minute": pmDoNotDisturbToTime.minute
        ]
        storage.setObject(toTimeDictionary as NSCoding, forKey: ConstantKeys.pmDoNotDisturbToTime)
        storage.setObject(activeForumNameList as NSCoding, forKey: ConstantKeys.activeForumNameList)
        storage.setObject(isEnabledUserRemark as NSCoding, forKey: ConstantKeys.isEnabledUserRemark)
        storage.setObject(userRemarkDictionary as NSCoding, forKey: ConstantKeys.userRemarkDictionary)
        storage.setObject(isEnabledTail as NSCoding, forKey: ConstantKeys.isEnabledTail)
        storage.setObject(tailText as NSCoding, forKey: ConstantKeys.tailText)
        if let url = tailURL {
            let urlString = url.absoluteString
            storage.setObject(urlString as NSCoding, forKey: ConstantKeys.tailURL)
        } else {
            storage.setObject(nil, forKey: ConstantKeys.tailURL)
        }
        storage.setObject(avatarImageResolution.rawValue as NSCoding, forKey: ConstantKeys.avatarImageResolution)
        storage.setObject(autoLoadImageViaWWAN as NSCoding, forKey: ConstantKeys.autoLoadImageViaWWAN)
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
        useAvatarPlaceholder = true
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
        CacheManager.settings.shared!.setObject(true as NSNumber, forKey: "kFirstLaunch")
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
