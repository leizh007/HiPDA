//
//  EventBus.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/13.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

/// 事件总线
class EventBus {
    /// 账户变更的Variable
    let accountChanged: Variable<Account?> = Variable(nil)
}
