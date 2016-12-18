//
//  PmDoNotDisturbTimeSettingViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/18.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

typealias PmDoNotDisturbTimeSettingCompletionHandler = (PmDoNotDisturbTime, PmDoNotDisturbTime) -> Void

class PmDoNotDisturbTimeSettingViewController: BaseViewController {
    var fromTime: PmDoNotDisturbTime!
    var toTime: PmDoNotDisturbTime!
    var completion: PmDoNotDisturbTimeSettingCompletionHandler?
}
