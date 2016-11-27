//
//  XibLoadable.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 可以从xib中加载
protocol XibLoadable {
    
}

extension XibLoadable where Self: UIView {
    /// 从xib初始化一个实例
    static var xibInstance: Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)![0] as! Self
    }
}
