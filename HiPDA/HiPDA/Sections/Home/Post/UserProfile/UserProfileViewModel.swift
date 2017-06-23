//
//  UserProfileViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserProfileViewModel {
    private var disposeBag = DisposeBag()
    private var model = UserProfileModel(sections: [])
    let uid: Int
    init(uid: Int) {
        self.uid = uid
    }
    
    func refresh(completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        disposeBag = DisposeBag()
        HiPDAProvider.request(.userProfile(uid: uid))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { try UserProfileModel.createInstance(from: $0) }
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let model):
                    console(message: String(describing: model))
                    completion(.success(()))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - DataSource

