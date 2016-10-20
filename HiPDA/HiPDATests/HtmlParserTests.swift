//
//  HtmlParserTests.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/20.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

/// Html解析的测试类
class HtmlParserTests: XCTestCase {
    /// 测试uid的获取
    func testUid() {
        let content = "space.php?uid=697558\""
        do {
            let uid = try HtmlParser.uid(from: content)
            XCTAssert(uid == 697558)
        } catch {
            XCTFail()
        }
    }
    
    /// 测试失败信息的获取
    func testLoginError() {
        let content1 = "<em id=\"returnmessage\" class=\"onerror\">登录失败，您还可以尝试 3 次  </em>"
        guard case let LoginError.nameOrPasswordUnCorrect(timesToRetry: count) = HtmlParser.loginError(from: content1), count == 3 else {
            XCTFail()
            return
        }
        
        let content2 = "<em id=\"returnmessage\" class=\"onerror\">密码错误次数过多，请 15 分钟后重新登录</em>"
        guard  .attempCountExceedsLimit == HtmlParser.loginError(from: content2) else {
            XCTFail()
            return
        }
    }
    
    /// 测试获取登录成功的用户名
    func testLoggedInUsename() {
        let content = "欢迎您回来，leizh007。现在将转入登录前页面。"
        XCTAssert(try HtmlParser.loggedInUserName(from: content) == "leizh007")
    }
    
    /// 测试登录结果
    func testLoginResult() {
        let content1 = "<em id=\"returnmessage\" class=\"onerror\">登录失败，您还可以尝试 2 次  </em>"
        do {
            _ = try HtmlParser.loginResult(of: "leizh007", from: content1)
        } catch LoginError.nameOrPasswordUnCorrect(timesToRetry: let count) {
            XCTAssert(count == 2)
        } catch {
            XCTFail()
        }
        
        let content2 = "<em id=\"returnmessage\" class=\"onerror\">密码错误次数过多，请 15 分钟后重新登录</em>"
        do {
            _ = try HtmlParser.loginResult(of: "leizh007", from: content2)
        } catch LoginError.attempCountExceedsLimit {
            
        } catch {
            XCTFail()
        }
        
        let content3 = "\"space.php?uid=697558\" class=\"noborder\">leizh007dowline\" />\n<div class=\"postbox\"><div class=\"alert_info\">\n<p>欢迎您回来，leizh007。现在将转入登录前页面。  </p>\n</div></div>\n</div>\n</div></div></di"
        do {
            let uid = try HtmlParser.loginResult(of: "leizh007", from: content3)
            XCTAssert(uid == 697558)
        } catch {
            XCTFail()
        }
        
        do {
            _ = try HtmlParser.loginResult(of: "TestAccount", from: content3)
        } catch LoginError.alreadyLoggedInAnotherAccount(let name) {
            XCTAssert(name == "leizh007")
        } catch {
            XCTFail()
        }
    }
}
