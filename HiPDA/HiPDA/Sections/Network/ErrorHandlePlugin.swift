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
    case forbidden = 403
}

extension NetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case .timeOut:
            return "请求超时"
        case .offline:
            return "网络不给力"
        case .forbidden:
            return "拒绝访问"
        }
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        return description
    }
}

public final class ErrorHandlePlugin: PluginType {
    public func process(_ result: Result<Moya.Response, MoyaError>, target: Moya.TargetType) -> Result<Moya.Response, MoyaError> {
        if case let .failure(requestError) = result,
            case let .underlying(underlyingError) = requestError,
            let networkError = NetworkError(rawValue: (underlyingError as NSError).code) {
            let error = underlyingError as NSError
            let domain = error.domain
            let code = error.code
            var userInfo = error.userInfo
            userInfo[NSLocalizedDescriptionKey] = networkError.description
            return Result.failure(.underlying(NSError(domain: domain, code: code, userInfo: userInfo)))
        } else if case let .success(response) = result, response.statusCode == NetworkError.forbidden.rawValue {
            return Result.failure(.underlying(NSError(domain: "HiPDA", code: NetworkError.forbidden.rawValue, userInfo: [NSLocalizedDescriptionKey : NetworkError.forbidden.description])))
        } else {
            return result
        }
    }
}
