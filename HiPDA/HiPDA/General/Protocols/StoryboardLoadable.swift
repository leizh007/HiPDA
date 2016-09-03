//
//  StoryboardLoadable.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 可以从storyboard中加载
protocol StoryboardLoadable {

}

extension StoryboardLoadable where Self: UIViewController {
    static var identifier: String {
        return "\(self)"
    }
}
