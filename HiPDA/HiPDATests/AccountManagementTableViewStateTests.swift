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
    fileprivate let model1 = AccountCellModel(name: "name1", uid: "uid1", avatarImageURL: URL(string: "https://www.hi-pda.com/forum/forumdisplay.php?fid=2")!, accessoryType: .checkmark)
    fileprivate var item1: AccountItemType!
    fileprivate let model2 = AccountCellModel(name: "name2", uid: "uid2", avatarImageURL: URL(string: "https://www.hi-pda.com/forum/forumdisplay.php?fid=2")!, accessoryType: .none)
    fileprivate var item2: AccountItemType!
    fileprivate let addItem = AccountItemType.addAccount
    fileprivate let logoutItem = AccountItemType.logout
    
    override func setUp() {
        super.setUp()
        
        item1 = .account(model1)
        item2 = .account(model2)
    }
    
    func testReplace() {
        let state1 = AccountManagementTableViewState(sections: [])
        let state2 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item1])])
        XCTAssert(state1.execute(.replace(state2)) == state2)
    }
    
    func testInsert() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item1, addItem]), AccountManagementSection(items: [logoutItem])])
        XCTAssert(state1.execute(.insert(item2, at: IndexPath(item: 1, section: 0))) == AccountManagementTableViewState(sections: [AccountManagementSection(items: [item1, item2, addItem]), AccountManagementSection(items: [logoutItem])]))
    }
    
    func testMove() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item1, item2, addItem]), AccountManagementSection(items: [logoutItem])])
        let state2 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item2, item1, addItem]), AccountManagementSection(items: [logoutItem])])
        XCTAssert(state1.execute(.move(from: IndexPath(row: 1, section: 0), to: IndexPath(row: 0, section: 0))) == state2)
    }
    
    func testDelete() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item1, item2, addItem]), AccountManagementSection(items: [logoutItem])])
        let state2 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item2, addItem]), AccountManagementSection(items: [logoutItem])])
        XCTAssert(state1.execute(.delete(with: IndexPath(row: 0, section: 0))) == state2)
    }
    
    func testClick() {
        let state1 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [item1, item2, addItem]), AccountManagementSection(items: [logoutItem])])
        let newModel1 = AccountCellModel.lens.accessoryType.set(.none, model1)
        let newModel22 = AccountCellModel.lens.accessoryType.set(.checkmark, model2)
        let state2 = AccountManagementTableViewState(sections: [AccountManagementSection(items: [.account(newModel1), .account(newModel22), addItem]), AccountManagementSection(items: [logoutItem])])
        XCTAssert(state1.execute(.click(with: IndexPath(row: 0, section: 0))).execute(.click(with: IndexPath(row: 1, section: 0))) == state2)
    }
}
