//
//  userTests.swift
//  Hi!PDA
//
//  Created by leizh007 on 16/6/13.
//  Copyright © 2016年 Hi!PDA. All rights reserved.
//

import XCTest
@testable import Hi_PDA

class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEqual() {
        let user1 = User(name: "leizh007", uid: 697558)
        let user2 = User(name: "leizh007", uid: 697558)
        let user3 = User(name: "德国大炮", uid: 876900)
        
        XCTAssert(user1 == user2, "User should be equal!")
        XCTAssert(user1 != user3, "User should not be equal!")
    }
    
    func testAvatarImageURL() {
        let user = User(name: "leizh007", uid: 697558)
        let avatarImageURLString = user.avatarImageURL.absoluteString
        
        XCTAssert(avatarImageURLString == "http://img.hi-pda.com/forum/uc_server/data/avatar/000/69/75/58_avatar_middle.jpg", "user avatarImageURL create failed!")
    }
    
    func testSerializable() {
        let user = User(name: "leizh007", uid: 697558)
        let userData = user.encode()
        
        XCTAssert(User(data: userData) == user, "User should conform to Serializable protocol!")
        XCTAssert(User(data: userData).name == user.name, "User should conform to Serializable protocol!")
    }
}
