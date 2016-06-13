//
//  AccountTests.swift
//  Hi!PDA
//
//  Created by leizh007 on 16/6/13.
//  Copyright © 2016年 Hi!PDA. All rights reserved.
//

import XCTest
@testable import Hi_PDA

class AccountTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEqual() {
        let account1 = Account(name: "leizh007", uid: 697558, questionid: 0, answer: "", password: "")
        let account2 = Account(name: "leizh007", uid: 697558, questionid: 0, answer: "", password: "")
        let account3 = Account(name: "德国大炮", uid: 876900, questionid: 0, answer: "", password: "")
        
        XCTAssert(account1 == account2, "Account should be equal!")
        XCTAssert(account1 != account3, "Account should not be equal!")
    }
    
    func testAvatarImageURL() {
        let account = Account(name: "leizh007", uid: 697558, questionid: 0, answer: "", password: "")
        let avatarImageURLString = account.avatarImageURL.absoluteString
        
        XCTAssert(avatarImageURLString == "http://img.hi-pda.com/forum/uc_server/data/avatar/000/69/75/58_avatar_middle.jpg", "Account avatarImageURL create failed!")
    }
    
    func testSerializable() {
        let account = Account(name: "leizh007", uid: 697558, questionid: 2, answer: "testAnswer", password: "testPassword")
        let accountData = account.encode()
        let accountFromData = Account(data: accountData)
        
        XCTAssert(accountFromData == account, "Account should conform to Serializable protocol!")
        XCTAssert(accountFromData.password == "testPassword", "Account password saved error!")
        XCTAssert(accountFromData.name == account.name, "Account password saved error!")
        XCTAssert(accountFromData.questionid == account.questionid, "Account password saved error!")
        XCTAssert(accountFromData.answer == account.answer, "Account password saved error!")
    }
}
