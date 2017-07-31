//
//  SettingsTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/25.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

func ==(lhs:Array<Account>, rhs:Array<Account>) -> Bool {
    var result = true
    if lhs.count != rhs.count {
        result = false
    } else {
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                result = false
                break
            }
        }
    }
    
    return result
}

class SettingsTests: XCTestCase {
    func testSettings() {
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        Settings.shared.reset()
        let settings = Settings.shared
        
        XCTAssert(settings.autoDownloadImageWhenUsingWWAN)
        XCTAssert(settings.autoDownloadImageSizeThreshold == 256 * 1024)
        XCTAssert(settings.fontSize == 17)
        XCTAssert(settings.lineSpacing == 1)
        XCTAssert(settings.isEnabledUserBlock)
        XCTAssert(settings.userBlockList == [])
        XCTAssert(!settings.isEnabledThreadBlock)
        XCTAssert(settings.threadBlockWordList == [])
        XCTAssert(settings.threadHistoryCountLimit == 100)
        XCTAssert(settings.isEnabledMessagePush)
        XCTAssert(settings.isEnabledSystemPm)
        XCTAssert(settings.isEnabledFriendPm)
        XCTAssert(settings.isEnabledThreadPm)
        XCTAssert(settings.isEnabledPrivatePm)
        XCTAssert(settings.isEnabledAnnoucePm)
        XCTAssert(settings.isEnabledPmDoNotDisturb)
        XCTAssert(settings.pmDoNotDisturbFromTime == (hour: 22, minute: 0))
        XCTAssert(settings.pmDoNotDisturbToTime == (hour:9, minute: 0))
        let defalutForumNameList = ["Discovery", "Buy & Sell 交易服务区", "E-INK", "Geek Talks · 奇客怪谈", "疑似机器人"]
        XCTAssert(settings.activeForumNameList == defalutForumNameList)
        XCTAssert(!settings.isEnabledUserRemark)
        XCTAssert(settings.userRemarkDictionary == [:])
        XCTAssert(settings.isEnabledTail)
        XCTAssert(settings.tailText == "小尾巴~")
        XCTAssert(settings.tailURL == URL(string: "https://www.hi-pda.com/forum/viewthread.php?tid=2137250&extra=&page=1")!)
        XCTAssert(settings.avatarImageResolution == .middle)
        
        /// 改变settings里面参数的值
        settings.autoDownloadImageWhenUsingWWAN = false
        settings.autoDownloadImageSizeThreshold = 512
        settings.fontSize = 20
        settings.lineSpacing = 4
        settings.isEnabledUserBlock = false
        settings.userBlockList = ["username1", "username2"]
        settings.isEnabledThreadBlock = true
        settings.threadBlockWordList = ["threadBlockWord1", "threadBlockWord2"]
        settings.threadHistoryCountLimit = 200
        settings.isEnabledMessagePush = false
        settings.isEnabledSystemPm = false
        settings.isEnabledFriendPm = false
        settings.isEnabledThreadPm = false
        settings.isEnabledPrivatePm = false
        settings.isEnabledAnnoucePm = false
        settings.isEnabledPmDoNotDisturb = false
        settings.pmDoNotDisturbFromTime = (hour: 23, minute: 30)
        settings.pmDoNotDisturbToTime = (hour: 12, minute: 30)
        settings.activeForumNameList = ["Discovery", "Buy & Sell 交易服务区", "疑似机器人"]
        settings.isEnabledUserRemark = true
        settings.userRemarkDictionary = [
            "username1": "remark1",
            "username2": "remark2"
        ]
        settings.isEnabledTail = false
        settings.tailText = "大尾巴"
        settings.tailURL = nil
        settings.avatarImageResolution = .big
        settings.save()
        
        let setting1 = Settings.shared
        XCTAssert(!setting1.autoDownloadImageWhenUsingWWAN)
        XCTAssert(setting1.autoDownloadImageSizeThreshold == 512)
        XCTAssert(setting1.fontSize == 20)
        XCTAssert(setting1.lineSpacing == 4)
        XCTAssert(!setting1.isEnabledUserBlock)
        XCTAssert(setting1.userBlockList == ["username1", "username2"])
        XCTAssert(setting1.isEnabledThreadBlock)
        XCTAssert(setting1.threadBlockWordList == ["threadBlockWord1", "threadBlockWord2"])
        XCTAssert(setting1.threadHistoryCountLimit == 200)
        XCTAssert(!setting1.isEnabledMessagePush)
        XCTAssert(!setting1.isEnabledSystemPm)
        XCTAssert(!setting1.isEnabledFriendPm)
        XCTAssert(!setting1.isEnabledThreadPm)
        XCTAssert(!setting1.isEnabledPrivatePm)
        XCTAssert(!setting1.isEnabledAnnoucePm)
        XCTAssert(!setting1.isEnabledPmDoNotDisturb)
        XCTAssert(setting1.pmDoNotDisturbFromTime == (hour: 23, minute: 30))
        XCTAssert(setting1.pmDoNotDisturbToTime == (hour:12, minute: 30))
        XCTAssert(setting1.activeForumNameList == ["Discovery", "Buy & Sell 交易服务区", "疑似机器人"])
        XCTAssert(setting1.isEnabledUserRemark)
        XCTAssert(setting1.userRemarkDictionary == [
            "username1": "remark1",
            "username2": "remark2"
        ])
        XCTAssert(!setting1.isEnabledTail)
        XCTAssert(setting1.tailText == "大尾巴")
        XCTAssert(settings.avatarImageResolution == .big)
        
        settings.tailURL = URL(string: "http://www.hi-pda.com/forum/space.php?uid=697558")
        settings.save()
        
        let settings2 = Settings.shared
        XCTAssert(settings2.tailURL! == URL(string: "http://www.hi-pda.com/forum/space.php?uid=697558"))
        
        Settings.shared.reset()
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        
        for (key, value) in dictionary {
            userDefaults.set(value, forKey: key)
        }
        userDefaults.synchronize()
    }
}
