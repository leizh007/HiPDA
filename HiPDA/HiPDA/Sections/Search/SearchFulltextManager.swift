//
//  SearchFulltextManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class SearchFulltextManager {
    static func search(text: String, page: Int, completion: @escaping (HiPDA.Result<(totalPage: Int, models: [SearchFulltextModel]), NSError>) -> Void) -> Disposable {
        return HiPDAProvider.request(.search(type: .fulltext, text: text, page: page))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { (try HtmlParser.totalPage(from: $0), try HtmlParser.searchFulltextModels(from: $0)) }
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let (totalPage, models)):
                    completion(.success((totalPage: totalPage, models: models)))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
        }
    }
}
