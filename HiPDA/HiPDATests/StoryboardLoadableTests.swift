//
//  StoryboardLoadableTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class TestViewControllerForStoryboardLoadable: UIViewController, StoryboardLoadable {
    
}

class StoryboardLoadableTests: XCTestCase {
    /// 测试identifier
    func testIdentifier() {
        XCTAssert(TestViewControllerForStoryboardLoadable.identifier == "TestViewControllerForStoryboardLoadable")
    }
}
