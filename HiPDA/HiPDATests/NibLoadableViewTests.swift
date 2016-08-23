//
//  NibLoadableViewTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class TestView: UIView {
    
}

extension TestView: NibLoadableView {
    
}

class NibLoadableViewTests: XCTestCase {
    
    func testNibName() {
        XCTAssert(TestView.NibName == "TestView")
    }
    
}
