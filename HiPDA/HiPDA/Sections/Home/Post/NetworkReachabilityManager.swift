//
//  NetworkReachabilityManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import Alamofire

class NetworkReachabilityManager {
    static let shared = NetworkReachabilityManager()
    fileprivate init () {
        
    }
    
    let manager = Alamofire.NetworkReachabilityManager(host: "https://www.baidu.com/")
    
    var isReachable: Bool {
        return manager?.isReachable ?? false
    }
    
    var isReachableOnWWAN: Bool {
        return manager?.isReachableOnWWAN ?? false
    }
    
    var isReachableOnEthernetOrWiFi: Bool {
        return manager?.isReachableOnEthernetOrWiFi ?? false
    }
    
    @discardableResult
    public func startListening() -> Bool {
        return manager?.startListening() ?? false
    }
    
    func stopListening() {
        manager?.stopListening()
    }
}
