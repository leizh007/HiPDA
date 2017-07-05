//
//  SearchTitleModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct SearchTitleModel {
    let tid: Int
    let title: String
    let titleHighlightWordRanges: [NSRange]
    let forumName: String
    let user: User
    let time: String
    let readCount: Int
    let replyCount: Int
}
