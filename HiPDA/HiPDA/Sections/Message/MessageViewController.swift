//
//  NotificationViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 消息的ViewController
class MessageViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerUnReadMessagesCount()
    }
}

// MARK: - UnReadMessagesCount

extension MessageViewController {
    fileprivate func observerUnReadMessagesCount() {
        EventBus.shared.unReadMessagesCount
            .map { $0.totalMessagesCount == 0 ? nil : "\($0.totalMessagesCount)" }
            .drive(navigationController!.tabBarItem.rx.badgeValue)
            .disposed(by: disposeBag)
    }
}
