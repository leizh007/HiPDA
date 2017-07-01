//
//  MessageManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class UnReadMessagesCountManager {
    private let disposeBag = DisposeBag()
    static let shared = UnReadMessagesCountManager()
    private init() {
        observeEventBus()
    }
    
    fileprivate func observeEventBus() {
        EventBus.shared.activeAccount.asObservable()
            .subscribe(onNext: { loginResult in
                guard let loginResult = loginResult, case .success(_) = loginResult else {
                    return
                }
                // 去请求一下首页，获取一下未读消息的数量
                NetworkUtilities.html(from: "/forum/index.php")
            })
            .disposed(by: disposeBag)
    }
    
    static func handleUnReadMessagesCount(from html: String) {
        guard let threadMessagesCount = try? HtmlParser.messageCount(of: "帖子消息", from: html),
            let pmMessagesCount = try? HtmlParser.messageCount(of: "私人消息", from: html),
            let friendMessagesCount = try? HtmlParser.messageCount(of: "好友消息", from: html) else { return }
        let model = UnReadMessagesCountModel(threadMessagesCount: threadMessagesCount,
                                             privateMessagesCount: pmMessagesCount,
                                             friendMessagesCount: friendMessagesCount)
        EventBus.shared.dispatch(UnReadMessagesCountAction(model: model))
    }
}
