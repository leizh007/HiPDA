//
//  ReplyManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/14.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

struct ReplyPostManager {
    static func replyPost(fid: Int, tid: Int, content: String, success: PublishSubject<Int>, failure: PublishSubject<String>, disposeBag: DisposeBag) {
        NetworkUtilities.formhash(from: "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)") { result in
            switch result {
            case .success(let formhash):
                HiPDAProvider.request(.replyPost(fid: fid, tid: tid, content: content, formhash: formhash))
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .mapGBKString()
                    .observeOn(MainScheduler.instance)
                    .subscribe { event in
                        switch event {
                        case .next(let html):
                            if let errorMessage = try? HtmlParser.newThreadErrorMessage(from: html) {
                                failure.onNext(errorMessage)
                            } else {
                                success.onNext(tid)
                            }
                        case .error(let error):
                            failure.onNext(error.localizedDescription)
                        default:
                            break
                        }
                    }.disposed(by: disposeBag)
            case .failure(let error):
                failure.onNext(error.localizedDescription)
            }
        }
    }
}
