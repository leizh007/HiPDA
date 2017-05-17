//
//  UIAppearanceManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class UIAppearanceManager: Bootstrapping {
    func bootstrap(bootstrapped: Bootstrapped) throws {
        UINavigationBar.appearance().tintColor = C.Color.navigationBarTintColor
    }
}
