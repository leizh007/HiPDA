//
//  HiPDAProvider.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import Moya
import RxSwift

private func HiPDAManager() -> Manager {
    let configuration = URLSessionConfiguration.default
    var headers = Manager.defaultHTTPHeaders
    headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    headers["Accept-Encoding"] = "gzip, deflate, sdch"
    headers["Accept-Language"] = "zh-CN,zh;q=0.8,en;q=0.6"
    headers["Host"] = "www.hi-pda.com"
    headers["Proxy-Connection"] = "keep-alive"
    headers["Upgrade-Insecure-Requests"] = "1"
    headers["Content-Type"] = "application/x-www-form-urlencoded; charset=gbk"
    
    configuration.httpAdditionalHeaders = headers
    
    let manager = Manager(configuration: configuration)
    manager.startRequestsImmediately = false
    return manager
}

private func HiPDAEndpointMapping<Target: TargetType>(_ target: Target) -> Endpoint<Target> {
    let url = "\(target.baseURL.absoluteString)\(target.path)"
    return Endpoint(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
}

let HiPDAProvider = RxMoyaProvider<HiPDA>(endpointClosure:HiPDAEndpointMapping, manager: HiPDAManager())

extension Moya.Response {
    func mapGBKString() throws -> String {
        let cfEnc = CFStringEncodings.GB_18030_2000
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        guard let string = NSString(data: data, encoding: gbkEncoding) else {
            throw Error.stringMapping(self)
        }
        return string as String
    }
}

extension ObservableType where E == Response {
    public func mapGBKString() -> Observable<String> {
        return flatMap { response -> Observable<String> in
            return Observable.just(try response.mapGBKString())
        }
    }
}
