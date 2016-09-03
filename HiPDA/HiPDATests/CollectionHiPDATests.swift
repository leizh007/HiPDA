//
//  CollectionHiPDATests.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class CollectionHiPDATests: XCTestCase {
    /// 测试safe
    func testSafe() {
        let a = [1, 2, 3]
        XCTAssert(a.safe[0] == 1)
        XCTAssert(a.safe[-1] == nil)
        XCTAssert(a.safe[3] == nil)
    }
}
