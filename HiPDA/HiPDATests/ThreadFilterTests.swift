//
//  ThreadFilterTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class ThreadFilterTests: XCTestCase {
    func testSave() {
        let filter = ThreadFilter(typeName: "笔记本电脑", order: .dateline)
        ThreadFilterManager.shared.save(filter: filter, for: "Discovery")
        XCTAssert(ThreadFilterManager.shared.filter(for: "Discovery") == filter)
    }
}
