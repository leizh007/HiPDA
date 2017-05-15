//
//  StoryboardLoadable.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

enum StoryBoard: String {
    case main = "Main"
    case login = "Login"
    case pickerActionSheet = "PickerActionSheet"
    case me = "Me"
    case home = "Home"
}

/// 可以从storyboard中加载
protocol StoryboardLoadable {
    
}

extension StoryboardLoadable where Self: UIViewController {
    static var identifier: String {
        return "\(self)"
    }
    
    static func load(from storyboard: StoryBoard) -> Self {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: Self.identifier) as! Self
    }
}
