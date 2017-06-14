//
//  NewThreadViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

private enum Constant {
    static let contentLengthThreshold = 5
}

enum NewThreadError: Error {
    case cannotGetTid
    case unKnown(String)
}

extension NewThreadError: CustomStringConvertible {
    var description: String {
        switch self {
        case .cannotGetTid:
            return "无法获取tid"
        case .unKnown(let value):
            return value
        }
    }
}

typealias NewTheadResult = HiPDA.Result<Int, NewThreadError>

class NewThreadViewModel {
    fileprivate let type: NewThreadType
    fileprivate var disposeBag = DisposeBag()
    let success: PublishSubject<Int>
    let failure: PublishSubject<String>
    let isSendButtonEnabled: Driver<Bool>
    
    init(type: NewThreadType, typeName: Driver<String>, title: Driver<String>, content: Driver<String>, sendButtonPresed: PublishSubject<Void>) {
        self.type = type
        isSendButtonEnabled = Driver.combineLatest(title, content) { ($0, $1) }.map { (title, content) in
            switch type {
            case .new(fid: _):
                return !title.isEmpty && content.characters.count > Constant.contentLengthThreshold
            default:
                return content.characters.count > Constant.contentLengthThreshold
            }
        }
        success = PublishSubject<Int>()
        failure = PublishSubject<String>()
        let attribute = Driver.combineLatest(typeName, title, content) { (ForumManager.typeid(of: $0), $1, $2) }
        sendButtonPresed.withLatestFrom(attribute).asObservable().subscribe(onNext: { [weak self] (typeid, title, content) in
            switch type {
            case let .new(fid: fid):
                self?.postNewThread(fid: fid, typeid: typeid, title: title, content: content)
            case let .replyPost(fid: fid, tid: tid):
                self?.replyPost(fid: fid, tid: tid, content: content)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
    
    func postNewThread(fid: Int, typeid: Int, title: String, content: String) {
        let content = skinContent(content)
        NetworkUtilities.formhash(from: "/forum/post.php?action=newthread&fid=\(fid)") { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let formhash):
                HiPDAProvider.request(.newThread(fid: fid, typeid: typeid, title: title, content: content, formhash: formhash))
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .mapGBKString()
                    .observeOn(MainScheduler.instance)
                    .subscribe { event in
                        switch event {
                        case .next(let html):
                            self.handleNewThreadResult(html)
                        case .error(let error):
                            self.failure.onNext(error.localizedDescription)
                        default:
                            break
                        }
                    }.disposed(by: self.disposeBag)
            case .failure(let error):
                self.failure.onNext(error.localizedDescription)
            }
        }
    }
    
    fileprivate func handleNewThreadResult(_ result: String) {
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
    
    func replyPost(fid: Int, tid: Int, content: String) {
        let content = skinContent(content)
        NetworkUtilities.formhash(from: "/forum/post.php?action=reply&fid=\(fid)&tid=\(tid)") { [weak self] result in
            guard let `self` = self else { return }
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
                                self.failure.onNext(errorMessage)
                            } else {
                                self.success.onNext(tid)
                            }
                        case .error(let error):
                            self.failure.onNext(error.localizedDescription)
                        default:
                            break
                        }
                    }.disposed(by: self.disposeBag)
            case .failure(let error):
                self.failure.onNext(error.localizedDescription)
            }
        }
    }
    
    fileprivate func skinContent(_ content: String) -> String {
        if Settings.shared.isEnabledTail {
            if let urlString = Settings.shared.tailURL?.absoluteString, !urlString.isEmpty {
                let text = Settings.shared.tailText.isEmpty ? urlString : Settings.shared.tailText
                return "\(content)    [url=\(urlString)][size=1]\(text)[/size][/url]"
            } else if !Settings.shared.tailText.isEmpty {
                return "\(content)    [size=1]\(Settings.shared.tailText)[/size]"
            } else {
                return content
            }
        } else {
            return content
        }
    }
}
