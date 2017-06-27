//
//  UnReadMessagesCountAction.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Delta
import RxSwift
import RxCocoa

struct UnReadMessagesCountAction: ActionType {
    let model: UnReadMessagesCountModel
    
    func reduce(_ state: State) -> State {
        state.unReadMessagesCount.onNext(model)
        return state
    }
}
