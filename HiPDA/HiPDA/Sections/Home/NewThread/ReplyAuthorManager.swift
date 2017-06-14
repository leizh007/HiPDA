//
//  ReplyAuthorManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/14.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

struct ReplyAuthorManager {
    static func replyAuthor(fid: Int, tid: Int, pid: Int, content: String, success: PublishSubject<Int>, failure: PublishSubject<String>, disposeBag: DisposeBag) {
        NetworkUtilities.html(from: "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)&reppost=\(pid)") { result in
            switch result {
            case let .success(html):
                do {
                    let formhash = try NewThreadViewModel.value(for: "formhash", in: html)
                    let noticeauthor = try NewThreadViewModel.value(for: "noticeauthor", in: html)
                    let noticetrimstr = try NewThreadViewModel.value(for: "noticetrimstr", in: html)
                    let noticeauthormsg = try NewThreadViewModel.value(for: "noticeauthormsg", in: html)
                    let content = "\(noticetrimstr)\n\(content)"
                    HiPDAProvider.request(.replyAuthor(fid: fid, tid: tid, pid: pid, formhash: formhash, noticeauthor: noticeauthor, noticetrimstr: noticetrimstr, noticeauthormsg: noticeauthormsg, content: content))
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
                } catch {
                    failure.onNext(error.localizedDescription)
                }
            case let .failure(error):
                failure.onNext(error.localizedDescription)
            }
        }
    }

}
