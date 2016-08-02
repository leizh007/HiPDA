//
//  Settings.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/24.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 设置中心
class Settings {
    static let shared = Settings()
    
    /// 可用账户列表
    var accountList: [Account]
    private static let kAccountList = "accountList"
    
    /// 当前登录账户
    var activeAccount: Account?
    private static let kActiveAccount = "activeAccount"
    
    /// 添加账户
    ///
    /// - parameter account: 帐户
    ///
    /// - returns: 返回添加好帐户所在帐户列表中的下标
    func add(account: Account) -> Int {
        for (index, accountElement) in accountList.enumerated() {
            if accountElement == account {
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
    var fontSize: Float
    private static let kFontSize = "fontSize"
    
    /// 读帖子界面字体行间距
    var lineSpacing: Float
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
    
    /// 是否开启帖子关注
    var isEnabledThreadAttention: Bool
    private static let kIsEnabledThreadAttention = "isEnabledThreadAttention"
    
    /// 帖子关注单词列表
    var threadAttentionWordList: [String]
    private static let kThreadAttentionWordList = "threadAttentionWordList"
    
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
    var pmDoNotDisturbFromTime: (hour:Int, minute: Int)
    private static let kPmDoNotDisturbFromTime = "pmDoNotDisturbFromTime"
    
    /// 免打扰的结束时间
    var pmDoNotDisturbToTime: (hour: Int, minute: Int)
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
        let accountArray = (userDefaults.value(forKey: Self.kAccountList) as? [Data]) ?? [Data]()
        accountList = accountArray
            .map { Account($0) }
        activeAccount = (userDefaults.value(forKey: Self.kActiveAccount) as? Data)
            .flatMap { Account($0) }
        autoDownloadImageWhenUsingWWAN = boolValue(in: userDefaults, key: Self.kAutoDownloadImageWhenUsingWWAN, defalut: true)
        autoDownloadImageSizeThreshold = (userDefaults.value(forKey: Self.kAutoDownloadImageSizeThreshold) as? Int) ?? 256 * 1024
        fontSize = (userDefaults.value(forKey: Self.kFontSize) as? Float) ?? 17.0
        lineSpacing = (userDefaults.value(forKey: Self.kLineSpacing) as? Float) ?? 1.0
        isEnabledUserBlock = boolValue(in: userDefaults, key: Self.kIsEnabledUserBlock, defalut: true)
        userBlockList = (userDefaults.value(forKey: Self.kUserBlockList) as? [String]) ?? []
        isEnabledThreadBlock = boolValue(in: userDefaults, key: Self.kIsEnabledThreadBlock, defalut: false)
        threadBlockWordList = (userDefaults.value(forKey: Self.kThreadBlockWordList) as? [String]) ?? []
        isEnabledThreadAttention = boolValue(in: userDefaults, key: Self.kIsEnabledThreadAttention, defalut: false)
        threadAttentionWordList = (userDefaults.value(forKey: Self.kThreadAttentionWordList) as? [String]) ?? []
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
        let defalutForumNameList = ["Discovery", "Buy & Sell 交易服务区", "E-INK", "Geek Talks · 奇客怪谈", "疑似机器人"]
        activeForumNameList = (userDefaults.value(forKey: Self.kActiveForumNameList) as? [String]) ?? defalutForumNameList
        isEnabledUserRemark = boolValue(in: userDefaults, key: Self.kIsEnabledUserRemark, defalut: false)
        userRemarkDictionary = (userDefaults.value(forKey: Self.kUserRemarkDictionary) as? [String: String]) ?? [:]
        isEnabledTail = boolValue(in: userDefaults, key: Self.kIsEnabledTail, defalut: true)
        tailText = (userDefaults.value(forKey: Self.kTailText) as? String) ?? "小尾巴~"
        if boolValue(in: userDefaults, key: "kFirstLaunch", defalut: true) {
            tailURL = URL(string: "http://www.hi-pda.com/forum/viewthread.php?tid=1598240")
            userDefaults.set(false, forKey: "kFirstLaunch")
        } else {
            if let urlString = userDefaults.value(forKey: Self.kTailURL) as? String {
                tailURL = URL(string: urlString)
            }
        }
    }
    
    /// 持久化
    func save() {
        typealias `Self` = Settings
        
        let userDefaults = UserDefaults.standard
        let accountArray = accountList.map { $0.encode() }
        userDefaults.setValue(accountArray, forKey: Self.kAccountList)
        if let account = activeAccount {
            userDefaults.setValue(account.encode(), forKey: Self.kActiveAccount)
        } else {
            userDefaults.removeObject(forKey: Self.kActiveAccount)
        }
        userDefaults.set(autoDownloadImageWhenUsingWWAN, forKey: Self.kAutoDownloadImageWhenUsingWWAN)
        userDefaults.set(autoDownloadImageSizeThreshold, forKey: Self.kAutoDownloadImageSizeThreshold)
        userDefaults.set(fontSize, forKey: Self.kFontSize)
        userDefaults.set(lineSpacing, forKey: Self.kLineSpacing)
        userDefaults.set(isEnabledUserBlock, forKey: Self.kIsEnabledUserBlock)
        userDefaults.set(userBlockList, forKey: Self.kUserBlockList)
        userDefaults.set(isEnabledThreadBlock, forKey: Self.kIsEnabledThreadBlock)
        userDefaults.set(threadBlockWordList, forKey: Self.kThreadBlockWordList)
        userDefaults.set(isEnabledThreadAttention, forKey: Self.kIsEnabledThreadAttention)
        userDefaults.set(threadAttentionWordList, forKey: Self.kThreadAttentionWordList)
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
        userDefaults.set(isEnabledTail, forKey: Self.kIsEnabledTail)
        userDefaults.set(tailText, forKey: Self.kTailText)
        if let url = tailURL {
            let urlString = url.absoluteString
            userDefaults.set(urlString, forKey: Self.kTailURL)
        } else {
            userDefaults.removeObject(forKey: Self.kTailURL)
        }
        
        userDefaults.synchronize()
    }
    
    /// 恢复到默认设置
    func reset() {
        /// 清楚所有缓存
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        
        /// 设置默认值
        autoDownloadImageWhenUsingWWAN = true
        autoDownloadImageSizeThreshold = 256 * 1024
        fontSize = 17.0
        lineSpacing = 1.0
        isEnabledUserBlock = true
        userBlockList = []
        isEnabledThreadBlock = false
        threadBlockWordList = []
        isEnabledThreadAttention = false
        threadAttentionWordList = []
        isEnabledMessagePush = true
        isEnabledSystemPm = true
        isEnabledFriendPm = true
        isEnabledThreadPm = true
        isEnabledPrivatePm = true
        isEnabledAnnoucePm = true
        isEnabledPmDoNotDisturb = true
        pmDoNotDisturbFromTime = (hour: 22, minute: 0)
        pmDoNotDisturbToTime = (hour: 9, minute: 0)
        activeForumNameList = ["Discovery", "Buy & Sell 交易服务区", "E-INK", "Geek Talks · 奇客怪谈", "疑似机器人"]
        isEnabledUserRemark = false
        userRemarkDictionary = [:]
        isEnabledTail = true
        tailText = "小尾巴~"
        tailURL = URL(string: "http://www.hi-pda.com/forum/viewthread.php?tid=1598240")
    }
}
