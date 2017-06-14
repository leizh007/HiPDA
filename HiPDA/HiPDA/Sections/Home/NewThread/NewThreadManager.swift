//
//  NewThreadManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/14.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

struct NewThreadManager {
    static func postNewThread(fid: Int, typeid: Int, title: String, content: String, success: PublishSubject<Int>, failure: PublishSubject<String>, disposeBag: DisposeBag) {
        NetworkUtilities.formhash(from: "/forum/post.php?action=newthread&fid=\(fid)") { result in
            switch result {
            case .success(let formhash):
                HiPDAProvider.request(.newThread(fid: fid, typeid: typeid, title: title, content: content, formhash: formhash))
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .mapGBKString()
                    .observeOn(MainScheduler.instance)
                    .subscribe { event in
                        switch event {
                        case .next(let html):
                            NewThreadManager.handleNewThreadResult(html, success: success, failure: failure)
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
    
    fileprivate static  func handleNewThreadResult(_ result: String, success: PublishSubject<Int>, failure: PublishSubject<String>) {
        do {
            let tid = try HtmlParser.tid(from: result)
            success.onNext(tid)
        } catch {
            if let errorMessage = try? HtmlParser.newThreadErrorMessage(from: result) {
                failure.onNext(errorMessage)
            } else {
                failure.onNext(NewThreadError.cannotGetTid.description)
            }
        }
    }
}
