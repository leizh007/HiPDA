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
    static func replyPost(pageURLPath: String, fid: Int, tid: Int, content: String, imageNumbers: [Int], success: PublishSubject<String>, failure: PublishSubject<String>, disposeBag: DisposeBag) {
        NetworkUtilities.formhash(from: pageURLPath) { result in
            switch result {
            case .success(let formhash):
                HiPDAProvider.request(.replyPost(fid: fid, tid: tid, content: content, formhash: formhash, imageNumbers: imageNumbers))
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .mapGBKString()
                    .observeOn(MainScheduler.instance)
                    .subscribe { event in
                        switch event {
                        case .next(let html):
                            success.onNext(html)
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
