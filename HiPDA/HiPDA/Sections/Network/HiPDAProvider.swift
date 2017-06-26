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
#if DEBUG
    configuration.timeoutIntervalForRequest = 20 // as seconds, you can set your request timeout
    configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
#endif
    
    let manager = Manager(configuration: configuration)
    manager.startRequestsImmediately = false
    return manager
}

private func HiPDAEndpointMapping<Target: TargetType>(_ target: Target) -> Endpoint<Target> {
    let url = "\(target.baseURL.absoluteString)\(target.path)"
    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: GBKURLEncoding())
}

let HiPDAProvider = RxMoyaProvider<HiPDA.API>(endpointClosure:HiPDAEndpointMapping,
                                          manager: HiPDAManager(),
                                          plugins: [ErrorHandlePlugin()])

extension Moya.Response {
    func mapGBKString() throws -> String {
        let cfEnc = CFStringEncodings.GB_18030_2000
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        guard let string = NSString(data: data, encoding: gbkEncoding) else {
            throw MoyaError.stringMapping(self)
        }
        let html = (string as String).stringByDecodingHTMLEntities
        if let alertInfo = try? HtmlParser.alertInfo(from: html),
            !alertInfo.contains("欢迎您回来") && !alertInfo.contains("成功") {
            throw HtmlParserError.unKnown(alertInfo)
        }
        
        return html
    }
}

extension ObservableType where E == Response {
    public func mapGBKString() -> Observable<String> {
        return flatMap { response -> Observable<String> in
            return Observable.just(try response.mapGBKString())
        }
    }
}
