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

extension HiPDA {
    enum ThreadAttachment: String {
        case none
        case image
        case file
    }
}

extension HiPDA.ThreadAttachment {
    static func attacthment(from htmlString: String) -> HiPDA.ThreadAttachment {
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

extension HiPDA.ThreadAttachment: Serializable { }

// MARK: - Decodable

extension HiPDA.ThreadAttachment: Decodable { }
