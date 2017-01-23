//
//  ActiveForumNameListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 版块列表修改完后的回调block
typealias ActiveForumNameListCompletionHandler = ([String]) -> Void

/// 版块列表
class ActiveForumNameListViewController: BaseViewController {
    var activeForumNameList = [String]() {
        didSet {
            
        }
    }
}
