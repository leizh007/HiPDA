//
//  URLProtocolManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class URLProtocolManager: Bootstrapping {
    func bootstrap(bootstrapped: Bootstrapped) throws {
        URLProtocol.wk_registerScheme(C.URL.Scheme.https)
        URLProtocol.wk_registerScheme(C.URL.Scheme.http)
        URLProtocol.registerClass(HiPDAURLProtocol.self)
    }
}
