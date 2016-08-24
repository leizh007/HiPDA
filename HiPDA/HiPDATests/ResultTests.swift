//
//  ResultTests.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

/// 测试Result失败信息
///
/// - testError: 失败
enum ResultTestError: Error {
    case testError
}

precedencegroup ResultPrecedence {
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

infix operator <==: ResultPrecedence

/// 是否是同类型的Result
///
/// - parameter lhs: 左侧Result
/// - parameter rhs: 右侧Result
///
/// - returns: 同是.success或同是.failure返回是，否则返回否
func <==<T, U>(lhs: Result<T>, rhs: Result<U>) -> Bool {
    switch (lhs, rhs) {
    case (.success(_), .success(_)):
        fallthrough
    case (.failure(_), .failure(_)):
        return true
    default:
        return false
    }
}

class ResultTests: XCTestCase {
    // 测试初始化方法
    func testInitAndResolve() {
        let failure = Result<String>.failure(ResultTestError.testError)
        let result1 = Result<String> { throw ResultTestError.testError }
        XCTAssert(result1 <== failure)
        
        let result2 = Result<Int> { 1 }
        XCTAssert(!(result2 <== failure))
        
        let success = Result<String>.success("test")
        XCTAssert(success <== result2)
        
        do {
            let value = try success.resolve()
            XCTAssert(value == "test")
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            _ = try failure.resolve()
        } catch {
            XCTAssert(error is ResultTestError)
        }
    }
    
    // 测试map方法
    func testMap() {
        let success = Result<String>.success("success")
        let failure = Result<String>.failure(ResultTestError.testError)
        
        let successOfMapped = success.map { $0 + "test" }
        XCTAssert(try! successOfMapped.resolve() == "successtest")
        
        do {
            _ = try success.map { (_) throws -> String in
                throw ResultTestError.testError
            }
        } catch {
            XCTAssert(error is ResultTestError)
        }
        
        let failureMapped = failure.map { $0 }
        do {
            _ = try failureMapped.resolve()
        } catch {
            XCTAssert(error is ResultTestError)
        }
    }
    
    // 测试flatMap
    func testFlatMap() {
        let success = Result<String>.success("success")
        let failure = Result<String>.failure(ResultTestError.testError)
        
        let successOfFlatMapped = success.flatMap { .success($0 + "test") }
        XCTAssert(try! successOfFlatMapped.resolve() == "successtest")
        
        do {
            _ = try success.flatMap { (_) throws -> Result<String> in
                throw ResultTestError.testError
            }
        } catch {
            XCTAssert(error is ResultTestError)
        }
        
        let failureFlatMapped = failure.flatMap { .success($0) }
        do {
            _ = try failureFlatMapped.resolve()
        } catch {
            XCTAssert(error is ResultTestError)
        }
    }
}
