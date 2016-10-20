//
//  GlobalState.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import RxSwift
import Delta

extension Variable: ObservablePropertyType {
    public typealias ValueType = Element
}

/// 全局的状态
struct State {
    /// 账户变更的Variable
    let accountChanged: Variable<Account?> = Variable(nil)
}
