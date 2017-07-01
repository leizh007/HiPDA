//
//  UnReadMessageCountModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct UnReadMessagesCountModel {
    // 帖子消息
    let threadMessagesCount: Int
    
    // 私人消息
    let privateMessagesCount: Int
    
    // 好友消息
    let friendMessagesCount: Int
    
    var totalMessagesCount: Int {
        return threadMessagesCount + privateMessagesCount + friendMessagesCount
    }
}
