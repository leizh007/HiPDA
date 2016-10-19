//
//  RegexTests.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/19.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

/// 正则表达式的测试类
class RegexTests: XCTestCase {
   /// 测试第一次匹配
    func testFirstMatch() {
        do {
            let result = try Regex.firstMatch(in: testString, of: regexPatternString)
            XCTAssert(result.count == 2)
            XCTAssert(result == ["uid=697558", "697558"])
        } catch {
            XCTFail("\(error)")
        }
    }
    
    /// 测试所有的匹配
    func testMatches() {
        do {
            let results = try Regex.matches(in: testString, of: regexPatternString)
            XCTAssert(results.count == 2)
            results.forEach { result in
                XCTAssert(result.count == 2)
                XCTAssert(result == ["uid=697558", "697558"])
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    private let regexPatternString = "uid=(\\d+)"
    private let testString = "<cite><a href=\"space.php?uid=697558&sid=YYp3pP<cite><a href=\"space.php?uid=697558&sid=YYp3pP"
}
