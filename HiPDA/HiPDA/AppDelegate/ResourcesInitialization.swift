//
//  ResourceInitialization.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class ResourcesInitialization: Bootstrapping {
    func bootstrap(bootstrapped: Bootstrapped) throws {
        _ = HtmlManager.html(with: "")
    }
}

