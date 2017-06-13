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
    case unKnown(String)
}

extension NewThreadError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unKnown(let value):
            return value
        }
    }
}

typealias NewTheadResult = HiPDA.Result<Int, NewThreadError>

class NewThreadViewModel {
    fileprivate var disposeBag = DisposeBag()
    func postNewThread(fid: Int, typeid: Int, title: String, content: String, completion: @escaping (NewTheadResult) -> Void = { _ in }) {
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
                            do {
                                let tid = try HtmlParser.tid(from: html)
                                completion(.success(tid))
                            } catch {
                                if let errorMessage = try? HtmlParser.newThreadErrorMessage(from: html) {
                                    completion(.failure(.unKnown(errorMessage)))
                                } else {
                                    completion(.failure(.unKnown(error.localizedDescription)))
                                }
                            }
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
}
