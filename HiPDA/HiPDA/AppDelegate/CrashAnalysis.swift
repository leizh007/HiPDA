//
//  CrashAnalysis.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/2.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

/// 崩溃问题分析模块
class CrashAnalysis: Bootstrapping {
    func bootstrap(bootstrapped: Bootstrapped) throws {
        Fabric.with([Crashlytics.self])
        #if DEBUG
            //PerformanceMonitor.shared().start()
        #endif
    }
}
