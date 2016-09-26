//
//  AccountTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/7/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA
import Argo
import Runes
import Curry

class AccountTests: XCTestCase {
    /// 测试账户的相等性
    func testAccoutEqual() {
        let account1 = Account(name: "leizh007",
                               uid: 697558,
                               questionid: 0,
                               answer: "",
                               password: "password")
        let account2 = Account(name: "leizh007",
                               uid: 697558,
                               questionid: 0,
                               answer: "",
                               password: "password")
        let account3 = Account(name: "德国大炮",
                               uid: 876900,
                               questionid: 0,
                               answer: "",
                               password: "password")
        
        XCTAssert(account1 == account2, "Account should be equal!")
        XCTAssert(account1 != account3, "Account should not be equal!")
    }
    
    /// 测试账户是否满足序列化
    func testAccountSerializable() {
        let account = Account(name: "leizh007",
                               uid: 697558,
                               questionid: 1,
                               answer: "answer",
                               password: "password")
        let accountData = account.encode()
        let accountFromData = Account(accountData)
        
        XCTAssert(account == accountFromData, "Account should conform to Serializable protocol!")
        
        let accountJSON: [String: Any] = [
            "name": "leizh007",
            "uid": 697558,
            "questionid": 1,
            "answer": "answer",
            "password": "password"
        ]
        
        do {
            let accountDecoded = try Account.decode(JSON(accountJSON)).dematerialize()
            XCTAssert(accountDecoded == account, "User should conform to Serializable protocol!")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
