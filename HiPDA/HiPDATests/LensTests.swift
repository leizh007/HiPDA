//
//  LensTests.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

struct TestStructA {
    let name: String
    let value: Int
}

struct TestStructB {
    let structA: TestStructA
    let name: String
}

class LensTests: XCTestCase {
    func testLens() {
        let strutANameLens: Lens<TestStructA, String> = Lens(get: { $0.name },
                                                             set: { TestStructA(name: $0, value: $1.value) })
        let structA = TestStructA(name: "heheda", value: 2)
        
        XCTAssert(strutANameLens.get(structA) == "heheda")
        
        let structA1 = strutANameLens.set("heheda1", structA)
        XCTAssert(strutANameLens.get(structA1) == "heheda1")
    }
    
    func testOperator() {
        let strutANameLens: Lens<TestStructA, String> = Lens(get: { $0.name },
                                                             set: { TestStructA(name: $0, value: $1.value) })
        let structBStructALens: Lens<TestStructB, TestStructA> = Lens(get: { $0.structA },
                                                                      set: { TestStructB(structA: $0, name: $1.name) })
        let structBStuctAName = structBStructALens >>> strutANameLens
        
        let structA = TestStructA(name: "testStructA", value: 2)
        let structB = TestStructB(structA: structA, name: "structB")
        
        XCTAssert(structBStuctAName.get(structB) == "testStructA")
        
        let structB2 = structBStuctAName.set("heheda", structB)
        XCTAssert(structBStuctAName.get(structB2) == "heheda")
    }
}
