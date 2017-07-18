//
//  QuoteManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/14.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

struct QuoteAuthorManager {
    static func quoteAuthor(pageURLPath: String, fid: Int, tid: Int, pid: Int, content: String, imageNumbers: [Int], success: PublishSubject<String>, failure: PublishSubject<String>, disposeBag: DisposeBag) {
        NetworkUtilities.html(from: pageURLPath) { result in
            switch result {
            case let .success(html):
                do {
                    let formhash = try HtmlParser.replyValue(for: "formhash", in: html)
                    let noticeauthor = try HtmlParser.replyValue(for: "noticeauthor", in: html)
                    let noticetrimstr = try HtmlParser.replyValue(for: "noticetrimstr", in: html)
                    let noticeauthormsg = try HtmlParser.replyValue(for: "noticeauthormsg", in: html)
                    let content = "\(noticetrimstr)\n\(content)"
                    HiPDAProvider.request(.quoteAuthor(fid: fid, tid: tid, pid: pid, formhash: formhash, noticeauthor: noticeauthor, noticetrimstr: noticetrimstr, noticeauthormsg: noticeauthormsg, content: content, imageNumbers: imageNumbers))
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
                } catch {
                    failure.onNext(error.localizedDescription)
                }
            case let .failure(error):
                failure.onNext(error.localizedDescription)
            }
        }
    }
}
