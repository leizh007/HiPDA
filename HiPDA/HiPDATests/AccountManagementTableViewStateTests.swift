//
//  AccountManagementTableViewStateTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/3/14.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class AccountManagementTableViewStateTests: XCTestCase {
    fileprivate let model1 = Account(name: "name1", uid: 123, questionid: 0, answer: "", password: "")
    fileprivate var item1: AccountItemType!
    fileprivate let model2 = Account(name: "name2", uid: 234, questionid: 0, answer: "", password: "")
    fileprivate var item2: AccountItemType!
    fileprivate let addItem = AccountItemType.addAccount
    fileprivate let logoutItem = AccountItemType.logout
    
    override func setUp() {
        super.setUp()
        
        item1 = .account(model1)
        item2 = .account(model2)
    }
    
    func testInsert() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(header: "0", items: [item1, addItem]), AccountManagementSection(header: "1", items: [logoutItem])])
        XCTAssert(state1.execute(.insert(item2, at: IndexPath(item: 1, section: 0))) == AccountManagementTableViewState(sections: [AccountManagementSection(header: "0", items: [item1, item2, addItem]), AccountManagementSection(header: "1", items: [logoutItem])]))
    }
    
    func testMove() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(header: "0", items: [item1, item2, addItem]), AccountManagementSection(header: "1", items: [logoutItem])])
        let state2 = AccountManagementTableViewState(sections: [AccountManagementSection(header: "0", items: [item2, item1, addItem]), AccountManagementSection(header: "1", items: [logoutItem])])
        XCTAssert(state1.execute(.move(from: IndexPath(row: 1, section: 0), to: IndexPath(row: 0, section: 0))) == state2)
    }
    
    func testDelete() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(header: "0", items: [item1, item2, addItem]), AccountManagementSection(header: "1", items: [logoutItem])])
        let state2 = AccountManagementTableViewState(sections: [AccountManagementSection(header: "0", items: [item2, addItem]), AccountManagementSection(header: "1", items: [logoutItem])])
        XCTAssert(state1.execute(.delete(with: IndexPath(row: 0, section: 0))) == state2)
    }
}
