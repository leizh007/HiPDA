//
//  ErrorHandlePlungin.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Moya
import Result

enum NetworkError:Int, Swift.Error {
    case timeOut = -1001 // NSURLErrorTimedOut
    case offline = -1009 // NSURLErrorNotConnectedToInternet
}

extension NetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case .timeOut:
            return "请求超时"
        case .offline:
            return "网络不给力"
        }
    }
}

public final class ErrorHandlePlugin: PluginType {
    public func process(_ result: Result<Moya.Response, MoyaError>, target: Moya.TargetType) -> Result<Moya.Response, MoyaError> {
        guard case let .failure(requestError) = result,
            case let .underlying(underlyingError) = requestError,
            let networkError = NetworkError(rawValue: (underlyingError as NSError).code) else { return result }
        let error = underlyingError as NSError
        let domain = error.domain
        let code = error.code
        var userInfo = error.userInfo
        userInfo[NSLocalizedDescriptionKey] = networkError.description
        return Result.failure(.underlying(NSError(domain: domain, code: code, userInfo: userInfo)))
    }
}
