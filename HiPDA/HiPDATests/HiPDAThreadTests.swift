//
//  HiPDAThreadTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA
import Argo
import Runes
import Curry

private func strictEqual(_ lhs: HiPDA.Thread, _ rhs: HiPDA.Thread) -> Bool {
    return lhs.id == rhs.id &&
    lhs.title == rhs.title &&
    lhs.attachment == rhs.attachment &&
    lhs.user == rhs.user &&
    lhs.postTime == rhs.postTime &&
    lhs.replyCount == rhs.replyCount &&
    lhs.readCount == rhs.readCount
}

class HiPDAThreadTests: XCTestCase {
    /// 测试账户是否满足序列化
    func testAccountSerializable() {
        let user = User(name: "ttolrats", uid: 681806)
        let thread = HiPDA.Thread(id: 2089676,
                                 title: "今天又被查身份证了",
                                 attachment: .none,
                                 user: user,
                                 postTime: "2017-5-4",
                                 replyCount: 22,
                                 readCount: 1135)
        let threadString = thread.encode()
        let threadData = threadString.data(using: .utf8)!
        let attributes = try! JSONSerialization.jsonObject(with: threadData, options: [])
        
        do {
            let threadDecoded = try HiPDA.Thread.decode(JSON(attributes)).dematerialize()
            XCTAssert(strictEqual(threadDecoded, thread), "HiPDAThread should conform to Serializable protocol!")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
