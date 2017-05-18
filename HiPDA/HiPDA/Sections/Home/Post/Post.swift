//
//  Post.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 帖子详情
struct Post {
    /// pid
    let id: Int
    
    /// 用户
    let user: User
    
    /// 发表时间
    let time: String
    
    /// 楼层
    let floor: Int
    
    /// 内容
    let content: String
}
