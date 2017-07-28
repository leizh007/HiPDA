//
//  HomeThreadModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/7.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

/// 帖子列表模型 for UI
/// 为了避免将model直接暴露给UI，将model做一下转换，直接对应到UI需要的各个属性
struct HomeThreadModel {
    /// 用户头像图片链接
    let avatarImageURL: URL
    
    /// 用户名
    let userName: String
    
    /// 回复数
    let replyCount: Int
    
    /// 阅读数
    let readCount: Int
    
    /// 时间描述字符串
    let timeString: String
    
    /// 标题
    let title: String
    
    var isRead: Bool
}
