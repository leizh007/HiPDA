//
//  SendShortMessageViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class SendShortMessageViewModel {
    private var disposeBag = DisposeBag()
    let user: User
    init(user: User) {
        self.user = user
    }
    
    func sendMessage(_ message: String, completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        disposeBag = DisposeBag()
        NetworkUtilities.formhash(from: "/forum/pm.php?action=new&uid=\(user.uid)") { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error as NSError))
            case .success(let formhash):
                HiPDAProvider.request(.sendShortMessage(username: self.user.name, message: message, formhash: formhash))
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .mapGBKString()
                    .map { return try HtmlParser.alertInfo(from: $0) }
                    .observeOn(MainScheduler.instance).subscribe { event in
                        switch event {
                        case .next(let info):
                            completion(.success(info))
                        case .error(let error):
                            completion(.failure(error as NSError))
                        default:
                            break
                        }
                    }.disposed(by: self.disposeBag)
            }
        }
    }
}
