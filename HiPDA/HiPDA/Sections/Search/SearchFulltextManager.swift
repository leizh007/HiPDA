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
        return Observable.just(1) as! Disposable
    }
}
