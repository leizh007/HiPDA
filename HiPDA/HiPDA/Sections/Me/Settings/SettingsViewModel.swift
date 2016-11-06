//
//  SettingsViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/6.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 设置的ViewModel
struct SettingsViewModel {
    /// disposeBag
    private let disposeBag = DisposeBag()
    
    init(settings: Settings, userBlock: Driver<Bool>, threadBlock: Driver<Bool>, threadAttention: Driver<Bool>, messagePush: Driver<Bool>, systemPm: Driver<Bool>, friendPm: Driver<Bool>, threadPm: Driver<Bool>, privatePm: Driver<Bool>, announcePm: Driver<Bool>, pmDoNotDisturb: Driver<Bool>, userRemark: Driver<Bool>, historyCountLimit: Driver<String>, tail: Driver<Bool>, tailText: Driver<String>, tailURL: Driver<String>) {
        userBlock.drive(onNext: { on in
                settings.isEnabledUserBlock = on
            }).addDisposableTo(disposeBag)
        threadBlock.drive(onNext: { on in
            settings.isEnabledThreadBlock = on
        }).addDisposableTo(disposeBag)
        threadAttention.drive(onNext: { on in
            settings.isEnabledThreadAttention = on
        }).addDisposableTo(disposeBag)
        messagePush.drive(onNext: { on in
            settings.isEnabledMessagePush = on
        }).addDisposableTo(disposeBag)
        systemPm.drive(onNext: { on in
            settings.isEnabledSystemPm = on
        }).addDisposableTo(disposeBag)
        friendPm.drive(onNext: { on in
            settings.isEnabledFriendPm = on
        }).addDisposableTo(disposeBag)
        threadPm.drive(onNext: { on in
            settings.isEnabledThreadPm = on
        }).addDisposableTo(disposeBag)
        privatePm.drive(onNext: { on in
            settings.isEnabledPrivatePm = on
        }).addDisposableTo(disposeBag)
        announcePm.drive(onNext: { on in
            settings.isEnabledAnnoucePm = on
        }).addDisposableTo(disposeBag)
        pmDoNotDisturb.drive(onNext: { on in
            settings.isEnabledPmDoNotDisturb = on
        }).addDisposableTo(disposeBag)
        userRemark.drive(onNext: { on in
            settings.isEnabledUserRemark = on
        }).addDisposableTo(disposeBag)
        historyCountLimit.drive(onNext: { text in
            settings.threadHistoryCountLimit = Int(text) ?? 100
        }).addDisposableTo(disposeBag)
        tail.drive(onNext: { on in
            settings.isEnabledTail = on
        }).addDisposableTo(disposeBag)
        tailText.drive(onNext: { text in
            settings.tailText = text
        }).addDisposableTo(disposeBag)
        tailURL.drive(onNext: { text in
            settings.tailURL = URL(string: text)
        }).addDisposableTo(disposeBag)
    }
}
