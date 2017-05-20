//
//  ResourceInitialization.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/19.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class ResourcesInitialization: Bootstrapping {
    private var disposeBag = DisposeBag()
    func bootstrap(bootstrapped: Bootstrapped) throws {
        // 加快帖子浏览页的初次载入速度
        _ = HtmlManager.html(with: "")
        
        EventBus.shared.activeAccount.asObservable()
            .subscribe(onNext: { [weak self] loginResult in
                guard let loginResult = loginResult, case .success(_) = loginResult else {
                    return
                }
                let readPostVC = PostViewController.getInstance()
                readPostVC.postInfo = PostInfo(tid: 0)
                _ = readPostVC.view
                self?.disposeBag = DisposeBag()
            })
            .disposed(by: disposeBag)
    }
}

