//
//  UserRemarkTableViewStateTests.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class UserRemarkTableViewStateTests: XCTestCase {
    private let userRemark1 = UserRemark(userName: "1", remarkName: "a")
    private let userRemark2 = UserRemark(userName: "2", remarkName: "b")
    private let userRemark3 = UserRemark(userName: "1", remarkName: "c")
    
    /// 测试append方法
    /// UserRemarkTableViewState单独实现了append方法,
    /// 其他默认的方法已经在EditWordListTableViewStateTests测试过了
    func testAppend() {
        var userRemarkTableViewState = UserRemarkTableViewState(sections: [UserRemarkSection(header: "0", attributes: [userRemark1])])
        
        let appendCommand1 = UserRemarkTableViewEditingCommand.append(userRemark2, in: 0)
        userRemarkTableViewState = userRemarkTableViewState.execute(appendCommand1)
        XCTAssert(userRemarkTableViewState == UserRemarkTableViewState(sections: [UserRemarkSection(header: "0", attributes: [userRemark1, userRemark2])]))
        
        let appendCommand2 = UserRemarkTableViewEditingCommand.append(userRemark3, in: 0)
        userRemarkTableViewState = userRemarkTableViewState.execute(appendCommand2)
        XCTAssert(userRemarkTableViewState == UserRemarkTableViewState(sections: [UserRemarkSection(header: "0", attributes: [userRemark3, userRemark2])]))
    }
}
