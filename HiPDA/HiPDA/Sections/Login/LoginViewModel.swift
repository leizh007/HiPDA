//
//  LoginViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/4.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 登录的ViewModel
struct LoginViewModel {
    /// 安全问题数组
    static let questions = [
        "安全问题",
        "母亲的名字",
        "爷爷的名字",
        "父亲出生的城市",
        "您其中一位老师的名字",
        "您个人计算机的型号",
        "您最喜欢的餐馆名称",
        "驾驶执照的最后四位数字"
    ]
    
    /// 登录按钮是否可点
    let loginEnabled: Driver<Bool>
    
    /// 正在登录过程中
    //let loggingin: Driver<Bool>
    
    /// 是否登录成功
    //let loggedIn: Driver<Bool>
    
    init(username: Driver<String>, password: Driver<String>, question: Driver<Int>, answer: Driver<String>) {
        loginEnabled = Driver.combineLatest(username, password, question, answer) { (username, password, question, answer) in
            username.characters.count > 0 &&
            password.characters.count > 0 &&
            (question == 0 || answer.characters.count > 0)
        }
    }
}
