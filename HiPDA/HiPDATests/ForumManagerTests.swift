//
//  ForumManagerTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class ForumManagerTests: XCTestCase {
    func testNumberOfForums() {
        XCTAssert(ForumManager.forums.count == 16)
    }
}
