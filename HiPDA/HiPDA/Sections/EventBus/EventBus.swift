//
//  EventBus.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/13.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import RxSwift
import RxCocoa
import Delta

/// 事件总线
struct EventBus: StoreType {
    static var shared = EventBus(State())
    var state: Variable<State>
    
    init(_ state: State) {
        self.state = Variable(state)
    }
}

extension EventBus {
    var activeAccount: Driver<LoginResult?> {
        return state.value.accountChanged
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
    }
    
    var unReadMessagesCount: Driver<UnReadMessagesCountModel> {
        let model = UnReadMessagesCountModel(threadMessagesCount: 0, pmMessagesCount: 0, friendMessagesCount: 0)
        return state.value.unReadMessagesCount
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: model)
    }
}
