//
//  Avatar.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct Avatar {
    /// 默认头像的图片
    static let placeholder =  #imageLiteral(resourceName: "avatar_placeholder").image(roundCornerRadius: Avatar.cornerRadius, borderWidth: 1.0, borderColor: .lightGray, size: CGSize(width: Avatar.width, height: Avatar.height))!
    
    static let width = 34.0 * kScreenScale
    static let height = 34.0 * kScreenScale
    static let cornerRadius = 2.5 * kScreenScale
}
