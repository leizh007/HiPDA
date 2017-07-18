//
//  SettingsSegue.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/18.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import Perform

/// 创建SettingsSegue错误
///
/// - unRecognizedIndexPath: indexPath无法识别
enum SettingsSugueError: Error {
    case unRecognizedIndexPath
}

enum SettingsSegue: String {
    case accountManagement = "账号管理"
    case userBlock = "黑名单列表"
    case threadBlock = "帖子过滤词组"
    case pmDoNotDisturb = "消息免打扰"
    case userRemark = "用户备注"
    case activeForumNameList = "版块列表"
    
    init(indexPath: IndexPath) throws {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self = .accountManagement
        case (2, 1):
            self = .userBlock
        case (3, 1):
            self = .threadBlock
        case (5, 7):
            self = .pmDoNotDisturb
        case (6, 0):
            self = .activeForumNameList
        case (8, 1):
            self = .userRemark
        default:
            throw SettingsSugueError.unRecognizedIndexPath
        }
    }
}

extension Segue {
    /// 账号管理
    static var accountManagement: Segue<AccountManagementViewController> {
        return .init(identifier: "AccountManagement")
    }
    
    /// 编辑词组
    static var editWords: Segue<EditWordListViewController> {
        return .init(identifier: "EditWords")
    }
    
    /// 编辑消息免打扰
    static var pmDoNotDisturb: Segue<PmDoNotDisturbTimeSettingViewController> {
        return .init(identifier: "PmDoNotDisturb")
    }
    
    /// 用户备注
    static var userRemark: Segue<UserRemarkViewController> {
        return .init(identifier: "UserRemark")
    }
    
    /// 版块列表
    static var activeForumNameList: Segue<ActiveForumNameListViewController> {
        return .init(identifier: "ActiveForumNameList")
    }
}
