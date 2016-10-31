//
//  HomeViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import Moya

/// 主页的ViewController
class HomeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Settings.shared.activeAccount != nil {
            self.showPromptInformation(of: .loading)
            EventBus.shared.activeAccount.drive(onNext: { [weak self] (result) in
                guard let `self` = self, let result = result else { return }
                self.hidePromptInformation()
                switch result {
                case .success(_):
                    self.showPromptInformation(of: .success("登录成功"))
                case .failure(let error):
                    self.showPromptInformation(of: .failure("\(error)"))
                }
            }).addDisposableTo(disposeBag)
        }
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        navigationItem.title = "Discovery"
    }
}
