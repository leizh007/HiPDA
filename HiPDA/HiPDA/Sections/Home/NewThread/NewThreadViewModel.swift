//
//  NewThreadViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

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
    fileprivate var disposeBag = DisposeBag()
    func postNewThread(fid: Int, typeid: Int, title: String, content: String, completion: @escaping (NewTheadResult) -> Void = { _ in }) {
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
                            self.handleNewThreadResult(html, completion: completion)
                        case .error(let error):
                            completion(.failure(.unKnown(error.localizedDescription)))
                        default:
                            break
                        }
                    }.disposed(by: self.disposeBag)
            case .failure(let error):
                completion(.failure(.unKnown(error.localizedDescription)))
            }
        }
    }
    
    fileprivate func handleNewThreadResult(_ result: String, completion: @escaping (NewTheadResult) -> Void = { _ in }) {
        do {
            let tid = try HtmlParser.tid(from: result)
            completion(.success(tid))
        } catch {
            if let errorMessage = try? HtmlParser.newThreadErrorMessage(from: result) {
                completion(.failure(.unKnown(errorMessage)))
            } else {
                completion(.failure(.cannotGetTid))
            }
        }
    }
}
