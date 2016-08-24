//
//  ReusableViewTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class TestTableViewCell: UITableViewCell {
    
}

class ReusableViewTests: XCTestCase {
    // 测试重用identifier
    func testReuseIdentifier() {
        XCTAssert(TestTableViewCell.reuseIdentifier == "TestTableViewCell")
    }
    
}
