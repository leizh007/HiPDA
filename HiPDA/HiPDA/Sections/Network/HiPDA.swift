//
//  HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import Moya

enum HiPDA {
    case login(Account)
}

extension HiPDA: TargetType {
    var baseURL: URL { return URL(string: "http://www.hi-pda.com")! }
    var path: String {
        switch self {
        case .login(_):
            return "/forum/logging.php?action=login&loginsubmit=yes"
        }
    }
    var method: Moya.Method {
        switch self {
        case .login(_):
            return .POST
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .login(let account):
            return [
                "loginfield": "username",
                "username": account.name,
                "password": account.password,
                "questionid": account.questionid,
                "answer": account.answer,
            ]
        }
    }
    var task: Task {
        return .request
    }
    var sampleData: Data {
        return Data()
    }
}
