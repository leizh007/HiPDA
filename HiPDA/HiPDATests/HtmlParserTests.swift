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
    
    /// 测试获取登录成功的用户名
    func testLoggedInUsename() {
        let content = "欢迎您回来，leizh007。现在将转入登录前页面。"
        XCTAssert(try HtmlParser.loggedInUserName(from: content) == "leizh007")
    }
    
    /// 测试登录结果
    func testLoginResult() {
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
    
    /// 测试获取帖子列表
    func testThreads() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "HtmlParserThreadsData", ofType: "txt") else {
            fatalError("HtmlParserThreadsData.txt not found")
        }
        
        guard let htmlString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) as String else {
            fatalError("Unable to convert HtmlParserThreadsData.txt to String")
        }
        do {
            let threads = try HtmlParser.threads(from: htmlString)
            XCTAssert(threads.count == 74)
        } catch {
            XCTFail()
        }
    }
    
    /// 测试帖子总数
    func testTotalPage() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "HtmlParserThreadsData", ofType: "txt") else {
            fatalError("HtmlParserThreadsData.txt not found")
        }
        
        guard let htmlString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) as String else {
            fatalError("Unable to convert HtmlParserThreadsData.txt to String")
        }
        do {
            let page = try HtmlParser.totalPage(from: htmlString)
            XCTAssert(page == 4510)
        } catch {
            XCTFail()
        }
        do {
            let page = try HtmlParser.totalPage(from: "测试字符串")
            XCTAssert(page == 1)
        } catch {
            XCTFail()
        }
    }
}
