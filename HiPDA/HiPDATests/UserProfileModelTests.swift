//
//  UserProfileModelTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/23.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class UserProfileModelTests: XCTestCase {
    func testCreate() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "UserProfileModelHtml", ofType: "txt") else {
            fatalError("UserProfileModelHtml.txt not found")
        }
        
        guard let htmlString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) as String else {
            fatalError("Unable to convert UserProfileModelHtml.txt to String")
        }
        let html = htmlString.stringByDecodingHTMLEntities
        var model: UserProfileModel!
        do {
            model = try UserProfileModel.createInstance(from: html)
        } catch {
            XCTFail()
        }
        XCTAssert(model.sections.count == 6)
        
        if case let .account(account) = model.sections[0] {
            XCTAssert(account.header == nil)
            XCTAssert(account.items.count == 1)
            XCTAssert(account.items[0] == User(name: "夏雪宜", uid: 500085))
        } else {
            XCTFail()
        }
        
        if case let .action(action) = model.sections[1] {
            XCTAssert(action.header == nil)
            XCTAssert(action.items == [.remark, .pm, .friend, .search, .block])
        } else {
            XCTFail()
        }
        
        if case let .baseInfo(baseInfo) = model.sections[2] {
            XCTAssert(baseInfo.header == "基本信息")
            XCTAssert(baseInfo.items == [ProfileBaseInfo(name: "性别", value: "保密"),
                                        ProfileBaseInfo(name: "来自", value: "苏州"),
                                        ProfileBaseInfo(name: "MSN", value: "")])
        } else {
            XCTFail()
        }
        
        if case let .baseInfo(baseInfo) = model.sections[3] {
            XCTAssert(baseInfo.header == "用户组: 版主")
            XCTAssert(baseInfo.items == [ProfileBaseInfo(name: "管理以下版块", value: "Discovery, Buy & Sell 交易服务区, 已完成交易"),
                                         ProfileBaseInfo(name: "注册日期", value: "2009-3-20"),
                                         ProfileBaseInfo(name: "上次访问", value: "2017-6-23 04:18"),
                                         ProfileBaseInfo(name: "最后发表", value: "2017-6-23 08:39"),
                                         ProfileBaseInfo(name: "发帖数级别", value: "西方失落～"),
                                         ProfileBaseInfo(name: "阅读权限", value: "100"),
                                         ProfileBaseInfo(name: "帖子", value: "98129 篇"),
                                         ProfileBaseInfo(name: "平均每日发帖", value: "32.53 篇"),
                                         ProfileBaseInfo(name: "精华", value: "0 篇"),
                                         ProfileBaseInfo(name: "页面访问量", value: "602348"),
                                         ProfileBaseInfo(name: "总计在线", value: "18421.5 小时"),
                                         ProfileBaseInfo(name: "本月在线", value: "95.17 小时")])
        } else {
            XCTFail()
        }
        
        if case let .baseInfo(baseInfo) = model.sections[4] {
            XCTAssert(baseInfo.header == "积分: 20")
            XCTAssert(baseInfo.items == [ProfileBaseInfo(name: "威望", value: "20"),
                                         ProfileBaseInfo(name: "金钱", value: "0")])
        } else {
            XCTFail()
        }
        
        if case let .baseInfo(baseInfo) = model.sections[5] {
            XCTAssert(baseInfo.header == "信用评价")
            XCTAssert(baseInfo.items == [ProfileBaseInfo(name: "买家信用评价", value: "0"),
                                         ProfileBaseInfo(name: "卖家信用评价", value: "0")])
        } else {
            XCTFail()
        }
    }
}
