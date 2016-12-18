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
    case userBlock = "黑名单列表"
    case threadBlock = "帖子过滤词组"
    case threadAttention = "帖子关注词组"
    case pmDoNotDisturb = "消息免打扰"
    
    init(indexPath: IndexPath) throws {
        switch (indexPath.section, indexPath.row) {
        case (2, 1):
            self = .userBlock
        case (3, 1):
            self = .threadBlock
        case (4, 1):
            self = .threadAttention
        case (6, 7):
            self = .pmDoNotDisturb
        default:
            throw SettingsSugueError.unRecognizedIndexPath
        }
    }
}

extension Segue {
    /// 编辑词组
    static var editWords: Segue<EditWordListViewController> {
        return .init(identifier: "EditWords")
    }
    
    /// 编辑消息免打扰
    static var pmDoNotDisturb: Segue<PmDoNotDisturbTimeSettingViewController> {
        return .init(identifier: "PmDoNotDisturb")
    }
}
