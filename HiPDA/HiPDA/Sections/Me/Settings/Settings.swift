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
    static let shared = Settings()
    
    /// 可用账户列表
    var accountList: [Account]
    private static let kAccountList = "accountList"
    
    /// 上次登录账户
    var lastLoggedInAccount: Account?
    private static let kLastLoggedInAccount = "lastLoggedInAccount"
    
    /// 当前登录账户
    var activeAccount: Account? {
        didSet {
            lastLoggedInAccount = activeAccount
        }
    }
    private static let kActiveAccount = "activeAccount"
    
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
    private static let kAutoDownloadImageWhenUsingWWAN = "autoDownloadImageWhenUsingWWAN"
    
    /// WWAN自动下载图片阈值，单位byte，默认256kb
    var autoDownloadImageSizeThreshold: Int
    private static let kAutoDownloadImageSizeThreshold = "autoDownloadImageSizeThreshold"
    
    /// 读帖子界面字体大小
    var fontSize: Int
    private static let kFontSize = "fontSize"
    
    /// 读帖子界面字体行间距
    var lineSpacing: Int
    private static let kLineSpacing = "lineSpacing"
    
    /// 是否开启黑名单过滤
    var isEnabledUserBlock: Bool
    private static let kIsEnabledUserBlock = "isEnabledUserBlock"
    
    /// 黑名单列表，屏蔽用户名
    var userBlockList: [String]
    private static let kUserBlockList = "userBlockList"
    
    /// 是否开启帖子过滤
    var isEnabledThreadBlock: Bool
    private static let kIsEnabledThreadBlock = "isEnabledThreadBlock"
    
    /// 帖子过滤单词列表
    var threadBlockWordList: [String]
    private static let kThreadBlockWordList = "threadBlockWordList"
    
    /// 浏览历史的条数
    var threadHistoryCountLimit: Int
    private static let kThreadHistoryCountLimit = "threadHistoryCountLimit"
    private static let kThreadHistoryCountDefault = 100
    
    /// 是否开启消息推送
    var isEnabledMessagePush: Bool
    private static let kIsEnabledMessagePush = "isEnabledMessagePush"
    
    /// 是否开启系统消息推送
    var isEnabledSystemPm: Bool
    private static let kIsEnabledSystemPm = "isEnabledSystemPm"
    
    /// 是否开启好友消息推送
    var isEnabledFriendPm: Bool
    private static let kIsEnabledFriendPm = "isEnabledFriendPm"
    
    /// 是否开启帖子消息推送
    var isEnabledThreadPm: Bool
    private static let kIsEnabledThreadPm = "isEnabledThreadPm"
    
    /// 是否开启私人消息推送
    var isEnabledPrivatePm: Bool
    private static let kIsEnabledPrivatePm = "isEnabledPrivatePm"
    
    /// 是否开启公共消息推送
    var isEnabledAnnoucePm: Bool
    private static let kIsEnabledAnnoucePm = "isEnabledAnnoucePm"
    
    /// 是否开启消息免打扰
    var isEnabledPmDoNotDisturb: Bool
    private static let kIsEnabledPmDoNotDisturb = "isEnabledPmDoNotDisturb"
    
    /// 免打扰的开始时间
    var pmDoNotDisturbFromTime: PmDoNotDisturbTime
    private static let kPmDoNotDisturbFromTime = "pmDoNotDisturbFromTime"
    
    /// 免打扰的结束时间
    var pmDoNotDisturbToTime: PmDoNotDisturbTime
    private static let kPmDoNotDisturbToTime = "pmDoNotDisturbToTime"
    
    /// 板块列表
    var activeForumNameList: [String]
    private static let kActiveForumNameList = "activeForumNameList"
    
    /// 是否开启用户备注
    var isEnabledUserRemark: Bool
    private static let kIsEnabledUserRemark = "isEnabledUserRemark"
    
    /// 用户备注字典，键为用户uid
    var userRemarkDictionary: [String: String]
    private static let kUserRemarkDictionary = "userRemarkDictionary"
    
    /// 是否开启小尾巴设置
    var isEnabledTail: Bool
    private static let kIsEnabledTail = "isEnabledTail"
    
    /// 小尾巴文字
    var tailText: String
    private static let kTailText = "tailText"
    
    /// 小尾巴链接
    var tailURL: URL?
    private static let kTailURL = "tailURL"
    
    /// 用户头像的分辨率
    var avatarImageResolution: UserAvatarImageResolution
    private static let kUserAvatarImageResolution = "avatarImageResolution"
    
    var autoLoadImageViaWWAN: Bool
    private static let kAutoLoadImageViaWWAN = "autoLoadImageViaWWAN"
    
    var threadOrder: HiPDA.ThreadOrder
    private static let kThreadOrder = "threadOrder"
    
    init() {
        typealias `Self` = Settings
        
        /// 从UserDefaluts里获取制定key的值
        ///
        /// - parameter userDefaults: UserDefaults
        /// - parameter key:          键
        /// - parameter defalut:      默认值
        ///
        /// - returns: 如果UserDefaults里存在key对应的值则返回，否则返回默认值
        func boolValue(in userDefaults: UserDefaults, key: String, defalut: Bool) -> Bool {
            return (userDefaults.value(forKey: key) as? Bool) ?? defalut
        }
        
        let userDefaults = UserDefaults.standard
        let accountNameArray = (userDefaults.value(forKey: Self.kAccountList) as? [String]) ?? []
        
        func account(with name: String) -> Account? {
            let accountString = SAMKeychain.password(forService: kAccountServiceKey, account: name) ?? ""
            let accountData = accountString.data(using: .utf8) ?? Data()
            guard let attributes = try? JSONSerialization.jsonObject(with: accountData, options: []) else { return nil }
            return try? Account.decode(JSON(attributes)).dematerialize()
        }
        accountList = accountNameArray.flatMap(account(with:))
        lastLoggedInAccount = (userDefaults.value(forKey: Self.kLastLoggedInAccount) as? String).flatMap(account(with:))
        
        autoDownloadImageWhenUsingWWAN = boolValue(in: userDefaults, key: Self.kAutoDownloadImageWhenUsingWWAN, defalut: true)
        autoDownloadImageSizeThreshold = (userDefaults.value(forKey: Self.kAutoDownloadImageSizeThreshold) as? Int) ?? 256 * 1024
        fontSize = (userDefaults.value(forKey: Self.kFontSize) as? Int) ?? 17
        lineSpacing = (userDefaults.value(forKey: Self.kLineSpacing) as? Int) ?? 1
        isEnabledUserBlock = boolValue(in: userDefaults, key: Self.kIsEnabledUserBlock, defalut: true)
        userBlockList = (userDefaults.value(forKey: Self.kUserBlockList) as? [String]) ?? []
        isEnabledThreadBlock = boolValue(in: userDefaults, key: Self.kIsEnabledThreadBlock, defalut: false)
        threadBlockWordList = (userDefaults.value(forKey: Self.kThreadBlockWordList) as? [String]) ?? []
        threadHistoryCountLimit = (userDefaults.value(forKey: Self.kThreadHistoryCountLimit) as? Int) ?? Self.kThreadHistoryCountDefault
        isEnabledMessagePush = boolValue(in: userDefaults, key: Self.kIsEnabledMessagePush, defalut: true)
        isEnabledSystemPm = boolValue(in: userDefaults, key: Self.kIsEnabledSystemPm, defalut: true)
        isEnabledFriendPm = boolValue(in: userDefaults, key: Self.kIsEnabledFriendPm, defalut: true)
        isEnabledThreadPm = boolValue(in: userDefaults, key: Self.kIsEnabledThreadPm, defalut: true)
        isEnabledPrivatePm = boolValue(in: userDefaults, key: Self.kIsEnabledPrivatePm, defalut: true)
        isEnabledAnnoucePm = boolValue(in: userDefaults, key: Self.kIsEnabledAnnoucePm, defalut: true)
        isEnabledPmDoNotDisturb = boolValue(in: userDefaults, key: Self.kIsEnabledPmDoNotDisturb, defalut: true)
        if let dictionary = userDefaults.value(forKey: Self.kPmDoNotDisturbFromTime) as? [String: Int],
            let hour = dictionary["hour"], let minute = dictionary["minute"] {
            pmDoNotDisturbFromTime = (hour: hour, minute: minute)
        } else {
            pmDoNotDisturbFromTime = (hour: 22, minute: 0)
        }
        if let dictionary = userDefaults.value(forKey: Self.kPmDoNotDisturbToTime) as? [String: Int],
            let hour = dictionary["hour"], let minute = dictionary["minute"] {
            pmDoNotDisturbToTime = (hour: hour, minute: minute)
        } else {
            pmDoNotDisturbToTime = (hour: 9, minute: 0)
        }
        activeForumNameList = (userDefaults.value(forKey: Self.kActiveForumNameList) as? [String]) ?? ForumManager.defalutForumNameList
        isEnabledUserRemark = boolValue(in: userDefaults, key: Self.kIsEnabledUserRemark, defalut: false)
        userRemarkDictionary = (userDefaults.value(forKey: Self.kUserRemarkDictionary) as? [String: String]) ?? [:]
        threadOrder = HiPDA.ThreadOrder(rawValue: (userDefaults.value(forKey: Self.kThreadOrder) as? String) ?? "lastpost") ?? .lastpost
        isEnabledTail = boolValue(in: userDefaults, key: Self.kIsEnabledTail, defalut: true)
        tailText = (userDefaults.value(forKey: Self.kTailText) as? String) ?? "小尾巴~"
        if boolValue(in: userDefaults, key: "kFirstLaunch", defalut: true) {
            tailURL = URL(string: "https://www.hi-pda.com/forum/viewthread.php?tid=2137250&extra=&page=1")
            userDefaults.set(false, forKey: "kFirstLaunch")
        } else {
            if let urlString = userDefaults.value(forKey: Self.kTailURL) as? String {
                tailURL = URL(string: urlString)
            }
        }
        avatarImageResolution = UserAvatarImageResolution(rawValue: userDefaults.string(forKey: Self.kUserAvatarImageResolution) ?? "middle") ?? .middle
        autoLoadImageViaWWAN = boolValue(in: userDefaults, key: Self.kAutoLoadImageViaWWAN, defalut: true)
    }
    
    /// 持久化
    func save() {
        typealias `Self` = Settings
        
        let userDefaults = UserDefaults.standard
        let accountNameArray = accountList.map { $0.name }
        if accountNameArray.count == 0 {
            userDefaults.removeObject(forKey: Self.kAccountList)
        } else {
            userDefaults.setValue(accountNameArray, forKey: Self.kAccountList)
            accountList.forEach { account in
                SAMKeychain.setPassword(account.encode(), forService: kAccountServiceKey, account: account.name)
            }
        }
        if let account = lastLoggedInAccount {
            userDefaults.setValue(account.name, forKey: Self.kLastLoggedInAccount)
        } else {
            userDefaults.removeObject(forKey: Self.kLastLoggedInAccount)
        }
        userDefaults.set(autoDownloadImageWhenUsingWWAN, forKey: Self.kAutoDownloadImageWhenUsingWWAN)
        userDefaults.set(autoDownloadImageSizeThreshold, forKey: Self.kAutoDownloadImageSizeThreshold)
        userDefaults.set(fontSize, forKey: Self.kFontSize)
        userDefaults.set(lineSpacing, forKey: Self.kLineSpacing)
        userDefaults.set(isEnabledUserBlock, forKey: Self.kIsEnabledUserBlock)
        userDefaults.set(userBlockList, forKey: Self.kUserBlockList)
        userDefaults.set(isEnabledThreadBlock, forKey: Self.kIsEnabledThreadBlock)
        userDefaults.set(threadBlockWordList, forKey: Self.kThreadBlockWordList)
        userDefaults.set(threadHistoryCountLimit, forKey: Self.kThreadHistoryCountLimit)
        userDefaults.set(isEnabledMessagePush, forKey: Self.kIsEnabledMessagePush)
        userDefaults.set(isEnabledSystemPm, forKey: Self.kIsEnabledSystemPm)
        userDefaults.set(isEnabledFriendPm, forKey: Self.kIsEnabledFriendPm)
        userDefaults.set(isEnabledThreadPm, forKey: Self.kIsEnabledThreadPm)
        userDefaults.set(isEnabledPrivatePm, forKey: Self.kIsEnabledPrivatePm)
        userDefaults.set(isEnabledAnnoucePm, forKey: Self.kIsEnabledAnnoucePm)
        userDefaults.set(isEnabledPmDoNotDisturb, forKey: Self.kIsEnabledPmDoNotDisturb)
        let fromTimeDictionary = [
            "hour": pmDoNotDisturbFromTime.hour,
            "minute": pmDoNotDisturbFromTime.minute
        ]
        userDefaults.set(fromTimeDictionary, forKey: Self.kPmDoNotDisturbFromTime)
        let toTimeDictionary = [
            "hour": pmDoNotDisturbToTime.hour,
            "minute": pmDoNotDisturbToTime.minute
        ]
        userDefaults.set(toTimeDictionary, forKey: Self.kPmDoNotDisturbToTime)
        userDefaults.set(activeForumNameList, forKey: Self.kActiveForumNameList)
        userDefaults.set(isEnabledUserRemark, forKey: Self.kIsEnabledUserRemark)
        userDefaults.set(userRemarkDictionary, forKey: Self.kUserRemarkDictionary)
        userDefaults.set(threadOrder.rawValue, forKey: Self.kThreadOrder)
        userDefaults.set(isEnabledTail, forKey: Self.kIsEnabledTail)
        userDefaults.set(tailText, forKey: Self.kTailText)
        if let url = tailURL {
            let urlString = url.absoluteString
            userDefaults.set(urlString, forKey: Self.kTailURL)
        } else {
            userDefaults.removeObject(forKey: Self.kTailURL)
        }
        userDefaults.set(avatarImageResolution.rawValue, forKey: Self.kUserAvatarImageResolution)
        userDefaults.set(autoLoadImageViaWWAN, forKey: Self.kAutoLoadImageViaWWAN)
        userDefaults.synchronize()
    }
    
    /// 恢复到默认设置
    func reset() {
        /// 清楚所有缓存
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys where key != Settings.kAccountList && key != Settings.kActiveAccount {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        
        /// 设置默认值
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
        threadOrder = .lastpost
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
                settings.save()
            } else {
                settings.activeAccount = nil
            }
        }
    }
}
