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
    case underlying(String)
}

extension NewThreadError: CustomStringConvertible {
    var description: String {
        switch self {
        case .cannotGetTid:
            return "无法获取tid"
        case .underlying(let value):
            return value
        }
    }
}

extension NewThreadError: LocalizedError {
    var errorDescription: String? {
        return description
    }
}

typealias NewTheadResult = HiPDA.Result<Int, NewThreadError>

class NewThreadViewModel {
    fileprivate let type: NewThreadType
    fileprivate var disposeBag = DisposeBag()
    let successNewThread: PublishSubject<Int>
    let successOther: PublishSubject<String>
    let failure: PublishSubject<String>
    let isSendButtonEnabled: Driver<Bool>
    let draftAfterCloseButtonPressed: PublishSubject<Draft?>
    var imageNumbers = [Int]()
    
    init(type: NewThreadType, typeName: Driver<String>, title: Driver<String>, content: Driver<String>, sendButtonPresed: PublishSubject<Void>, closeButtonPressed: PublishSubject<Void>) {
        self.type = type
        isSendButtonEnabled = Driver.combineLatest(title, content) { ($0, $1) }.map { (title, content) in
            switch type {
            case .new(fid: _):
                return !title.isEmpty && NewThreadViewModel.skinContent(content).characters.count > Constant.contentLengthThreshold
            default:
                return NewThreadViewModel.skinContent(content).characters.count > Constant.contentLengthThreshold
            }
        }
        successNewThread = PublishSubject<Int>()
        successOther = PublishSubject<String>()
        failure = PublishSubject<String>()
        draftAfterCloseButtonPressed = PublishSubject<Draft?>()
        let attribute = Driver.combineLatest(typeName, title, content) { (ForumManager.typeid(of: $0), $1, NewThreadViewModel.skinContent($2)) }
        sendButtonPresed.withLatestFrom(attribute).asObservable().subscribe(onNext: { [weak self] (typeid, title, content) in
            guard let `self` = self else { return }
            self.imageNumbers = self.imageNumbers.filter { num in
                content.contains("[attachimg]\(num)[/attachimg]")
            }
            switch type {
            case let .new(fid: fid):
                NewThreadManager.postNewThread(pageURLPath: type.pageURLPath, fid: fid, typeid: typeid, title: title, content: content, imageNumbers: self.imageNumbers, success: self.successNewThread, failure: self.failure, disposeBag: self.disposeBag)
            case let .replyPost(fid: fid, tid: tid):
                ReplyPostManager.replyPost(pageURLPath: type.pageURLPath, fid: fid, tid: tid, content: content, imageNumbers: self.imageNumbers, success: self.successOther, failure: self.failure, disposeBag: self.disposeBag)
            case let .replyAuthor(fid: fid, tid: tid, pid: pid):
                ReplyAuthorManager.replyAuthor(pageURLPath: type.pageURLPath, fid: fid, tid: tid, pid: pid, content: content, imageNumbers: self.imageNumbers, success: self.successOther, failure: self.failure, disposeBag: self.disposeBag)
            case let .quote(fid: fid, tid: tid, pid: pid):
                QuoteAuthorManager.quoteAuthor(pageURLPath: type.pageURLPath, fid: fid, tid: tid, pid: pid, content: content, imageNumbers: self.imageNumbers, success: self.successOther, failure: self.failure, disposeBag: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        closeButtonPressed.withLatestFrom(Driver.combineLatest(typeName, title, content) { ($0, $1, $2) })
            .asObservable()
            .subscribe(onNext: { [weak self] (typeName, title, content) in
                guard let `self` = self else { return }
                guard case .new(fid: let fid) = type else {
                    self.draftAfterCloseButtonPressed.onNext(nil)
                    return
                }
                let forumName = ForumManager.forumName(ofFid: fid)
                if typeName == "分类" && title.isEmpty && content.isEmpty && self.imageNumbers.isEmpty {
                    self.draftAfterCloseButtonPressed.onNext(nil)
                    return
                }
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "yyyy-M-d HH:mm:ss"
                let draft = Draft(fid: fid, forumName: forumName, typeName: typeName, time: dateFormater.string(from: Date()), title: title, content: content, imageNumbers: self.imageNumbers)
                self.draftAfterCloseButtonPressed.onNext(draft)
            }).disposed(by: disposeBag)
    }
    
    fileprivate static func skinContent(_ content: String) -> String {
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
