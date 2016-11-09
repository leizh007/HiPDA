//
//  EditWordListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/9.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

typealias EditWordListCompletion = ([String]) -> ()

/// 编辑单词列表的viewController
class EditWordListViewController: BaseViewController {
    var words: [String]!
    var completion: EditWordListCompletion?
}
