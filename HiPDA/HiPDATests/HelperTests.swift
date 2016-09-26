//
//  HelperTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/24.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class HelperTests: XCTestCase {
    func testDelay() {
        let expect = expectation(description: "Testing delay")
        
        let date = Date()
        delay(seconds: 1.0) { 
            let duration = date.timeIntervalSinceNow
            XCTAssert(fabs(duration + 1.0) <= 0.2)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { (error) in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error)")
            }
        }
    }
    
}
