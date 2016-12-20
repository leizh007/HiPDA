//
//  UserRemarkViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

/// 用户备注修改完后的回调block
typealias UserRemarkCompletionHandler = ([String: String]) -> Void

/// 用户备注的ViewController
class UserRemarkViewController: BaseViewController {
    var userRemarkDictionary = [String: String]()
    var complation: UserRemarkCompletionHandler?
}
