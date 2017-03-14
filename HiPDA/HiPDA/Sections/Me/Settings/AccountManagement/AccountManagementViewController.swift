//
//  AccountManagementViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

typealias AccountManagementCompletion = (AccountInfos) -> ()

/// 账户管理
class AccountManagementViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    var accountInfos: AccountInfos!
    var completion: AccountManagementCompletion?
}
