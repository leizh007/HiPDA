//
//  ResourceInitialization.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import SDWebImage
import AlamofireNetworkActivityIndicator

class ResourcesInitialization: Bootstrapping {
    private var disposeBag = DisposeBag()
    func bootstrap(bootstrapped: Bootstrapped) throws {
        let _ = EmoticonHelper.groups
        let _ = URLDispatchManager.shared
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.5
        NetworkActivityIndicatorManager.shared.completionDelay = 0.2
        // 最大图片缓存100MB
        SDImageCache.shared().config.maxCacheSize = UInt(pow(10.0, 8.0))
    }
}
