//
//  PostInfoTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class PostInfoTests: XCTestCase {
    func testInitialization1() {
        let urlString = "https://www.hi-pda.com/forum/viewthread.php?tid=2094735&extra=page%3D1&page=1"
        guard let postInfo = PostInfo(urlString: urlString) else {
            XCTFail()
            return
        }
        XCTAssert(postInfo == PostInfo(tid: 2094735, page: 1, pid: nil))
    }
    
    func testInitialization2() {
        let urlString = "https://www.hi-pda.com/forum/viewthread.php?tid=2094735&rpid=41821617&ordertype=0&page=1#pid41821617"
        guard let postInfo = PostInfo(urlString: urlString) else {
            XCTFail()
            return
        }
        XCTAssert(postInfo == PostInfo(tid: 2094735, page: 1, pid: 41821617))
    }
    
    func testInitialization3() {
        let urlString = "https://www.hi-pda.com/forum/viewthread.php?tid=2094735&extra=page%3D1&page=1"
        guard let postInfo = PostInfo(urlString: urlString) else {
            XCTFail()
            return
        }
        XCTAssert(postInfo == PostInfo(tid: 2094735, page: 1, pid: nil))
    }
    
    func testInitialization4() {
        let urlString = "https://www.hi-pda.com/forum/post.php?action=newthread&fid=2&special=1"
        if let _ = PostInfo(urlString: urlString)  {
            XCTFail()
        }
    }
}
