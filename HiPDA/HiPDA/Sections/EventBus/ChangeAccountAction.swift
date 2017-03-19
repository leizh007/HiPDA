//
//  ChangeAccountAction.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Delta

/// 改变用户的Action
struct ChangeAccountAction: ActionType {
    let account: LoginResult?
    
    func reduce(_ state: State) -> State {
        state.accountChanged.onNext(account)
        return state
    }
}
