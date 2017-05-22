//
//  Constants.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/30.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// C = Constant
enum C {
    enum UI {
        /// 屏幕宽度
        static let screenWidth = UIScreen.main.bounds.size.width
        
        /// 屏幕高度
        static let screenHeight = UIScreen.main.bounds.size.height
        
        /// 屏幕scale
        static let screenScale = UIScreen.main.scale
        
        /// 状态栏高度
        static let statusBarHeight: CGFloat = 20.0
        
        /// NavigationBar的高度
        static let navigationBarHeight: CGFloat = 44.0
        
        static let animationDuration = 0.25
    }
    
    enum Color {
        /// Tabbar的tint color
        static let tabbarTintColor = #colorLiteral(red: 0.1137254902, green: 0.6352941176, blue: 0.9490196078, alpha: 1)
        
        /// NavigationBar的tint color
        static let navigationBarTintColor = #colorLiteral(red: 0.1137254902, green: 0.6352941176, blue: 0.9490196078, alpha: 1)
    }
    
    enum Number {
        /// 主页在tabbarController中的下标
        static let homeViewControllerIndex = 0
    }
    
    enum URL {
        /// WebView的baseURL
        static let baseWebViewURL = Foundation.URL(string: "https://www.hi-pda.com/forum")!
        
        enum HiPDA {
            /// 标明图片
            static let image = "--hipda-image--"
            
            /// 标示头像
            static let avatar = "--hipda-avatar--"
        }
        
        enum Scheme {
            /// URLProtocol里用到的基本scheme
            static let https = "https"
            
            static let http = "http"
            
            /// HiPDA的scheme
            static let hipda = "hipda"
        }
    }
}
