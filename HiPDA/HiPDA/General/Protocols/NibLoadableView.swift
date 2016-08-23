//
//  NibLoadableView.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 可以从Nib进行加载的View
protocol NibLoadableView: class {
    
}

extension NibLoadableView where Self: UIView {
    static var NibName: String {
        return "\(self)"
    }
}
