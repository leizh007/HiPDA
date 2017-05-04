//
//  ThreadAttachment.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Argo
import Runes
import Curry

/// 帖子列表附件类型
///
/// - none: 没有附件
/// - image: 图片附件
/// - file: 文件附件
enum HiPDAThreadAttachment: String {
    case none
    case image
    case file
}

extension HiPDAThreadAttachment {
    static func attacthment(from htmlString: String) -> HiPDAThreadAttachment {
        if htmlString.contains("图片附件") {
            return .image
        } else if htmlString.contains("附件") {
            return .file
        } else {
            return .none
        }
    }
}

// MARK: - Serializable

extension HiPDAThreadAttachment: Serializable { }

// MARK: - Decodable

extension HiPDAThreadAttachment: Decodable { }
