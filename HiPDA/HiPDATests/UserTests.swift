//
//  UserTests.swift
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

class UserTests: XCTestCase {
    /// 测试User的相等性
    func testUserEqual() {
        let user1 = User(name: "leizh007", uid: 697558)
        let user2 = User(name: "leizh007", uid: 697558)
        let user3 = User(name: "德国大炮", uid: 876900)
        
        XCTAssert(user1 == user2, "User should be equal!")
        XCTAssert(user1 != user3, "User should not be equal!")
    }
    
    /// 测试User获取到的头像URL是否正确
    func testAvatarImageURL() {
        let user = User(name: "leizh007", uid: 697558)
        
        let smallResolution = UserAvatarImageResolution.small
        let smallAvatarImageURLString = user.avatarImageURL(with: smallResolution).absoluteString
        XCTAssert(smallAvatarImageURLString == "https://img02.hi-pda.com/forum/uc_server/data/avatar/000/69/75/58_avatar_small.jpg", "User avatarImageURL create failed!")
        
        let middleResulution = UserAvatarImageResolution.middle
        let middleAvatarImageURLString = user.avatarImageURL(with: middleResulution).absoluteString
        XCTAssert(middleAvatarImageURLString == "https://img02.hi-pda.com/forum/uc_server/data/avatar/000/69/75/58_avatar_middle.jpg", "User avatarImageURL create failed!")
        
        let bigResolution = UserAvatarImageResolution.big
        let bigAvatarImageURLString = user.avatarImageURL(with: bigResolution).absoluteString
        XCTAssert(bigAvatarImageURLString == "https://img02.hi-pda.com/forum/uc_server/data/avatar/000/69/75/58_avatar_big.jpg", "User avatarImageURL create failed!")
    }
    
    /// 测试User是否满足序列化
    func testUserSerializable() {
        let user = User(name: "leizh007", uid: 697558)
        let userString = user.encode()
        let userData = userString.data(using: .utf8)!
        let attributes = try! JSONSerialization.jsonObject(with: userData, options: [])
        
        do {
            let userDecoded = try User.decode(JSON(attributes)).dematerialize()
            XCTAssert(userDecoded == user, "User should conform to Serializable protocol!")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
