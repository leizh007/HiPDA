//
//  NetworkUtilities.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

typealias NetworkUtilitiesResult = HiPDA.Result<String, NSError>

class NetworkUtilities {
    fileprivate static var disposeBag = DisposeBag()
    static func formhash(from url: String, completion: @escaping (NetworkUtilitiesResult) -> Void = { _ in }) {
        NetworkUtilities.disposeBag = DisposeBag()
        HiPDAProvider.request(.formhash(url))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let html):
                    do {
                        let formhash = try HtmlParser.formhash(from: html)
                        completion(.success(formhash))
                    } catch {
                        completion(.failure(error as NSError))
                    }
                    break
                case .error(let error):
                    completion(.failure(error as NSError))
                    break
                default:
                    break
                }
            }.disposed(by: NetworkUtilities.disposeBag)
    }
    
    static func html(from urlPath: String, completion: @escaping (NetworkUtilitiesResult) -> Void = { _ in }) {
        NetworkUtilities.disposeBag = DisposeBag()
        HiPDAProvider.request(.html(urlPath))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let html):
                    completion(.success(html))
                    break
                case .error(let error):
                    completion(.failure(error as NSError))
                    break
                default:
                    break
                }
            }.disposed(by: NetworkUtilities.disposeBag)
    }
    
    static func addFriend(uid: Int, completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        NetworkUtilities.disposeBag = DisposeBag()
        HiPDAProvider.request(.addFriend(uid: uid))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { try HtmlParser.addFriendPromptInformation(from: $0) }
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let info):
                    completion(.success(info))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: NetworkUtilities.disposeBag)
    }
}
