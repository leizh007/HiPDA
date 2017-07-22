//
//  TipOffViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class TipOffViewModel {
    private var disposeBag = DisposeBag()
    let user: User
    init(user: User) {
        self.user = user
    }
    
    func sendMessage(_ message: String, completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        disposeBag = DisposeBag()
        NetworkUtilities.formhash(from: "/forum/pm.php?action=new&uid=\(user.uid)") { result in
            switch result {
            case .failure(let error):
                completion(.failure(error as NSError))
            case .success(_):
                delay(seconds: 0.5) {
                    completion(.success("举报成功!"))
                }
            }
        }
    }
}
