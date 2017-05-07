//
//  YYCacheExtensionTests.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA
import YYCache

class YYCacheExtensionTests: XCTestCase {
    let thread1 = HiPDAThread(id: 2089676,
                             title: "今天又被查身份证了",
                             attachment: .none,
                             user: User(name: "ttolrats", uid: 681806),
                             postTime: "2017-5-4",
                             replyCount: 22,
                             readCount: 1135)
    let thread2 = HiPDAThread(id: 1111111,
                              title: "Test",
                              attachment: .image,
                              user: User(name: "xxxxx", uid: 22222),
                              postTime: "2017-5-5",
                              replyCount: 2,
                              readCount: 234)
    
    private func executeTest(cache: YYCache, block: () -> () = { _ in }) {
        cache.clear()
        block()
        cache.clear()
    }
    
    func testHistoryCache() {
        guard let cache = CacheManager.threadsReadHistory.instance else {
            XCTFail()
            return
        }
        executeTest(cache: cache) {
            XCTAssert(cache.tids == [])
            cache.addThread(thread1)
            XCTAssert(cache.tids == [thread1.id])
            XCTAssert(cache.thread(for: thread1.id) == thread1)
            cache.addThread(thread2)
            XCTAssert(cache.thread(for: thread2.id) == thread2)
            XCTAssert(cache.tids == [thread2.id, thread1.id])
            XCTAssert(cache.thread(for: thread1.id) == thread1)
            XCTAssert(cache.tids == [thread1.id, thread2.id])
            cache.removeThread(thread1)
            XCTAssert(cache.thread(for: thread1.id) == nil)
            XCTAssert(cache.tids == [thread2.id])
        }
    }
    
    func testThreadsCache() {
        guard let cache = CacheManager.threads.instance else {
            XCTFail()
            return
        }
        executeTest(cache: cache) {
            XCTAssert(cache.tids == [])
            cache.addThread(thread1)
            XCTAssert(cache.tids == [thread1.id])
            XCTAssert(cache.thread(for: thread1.id) == thread1)
            cache.addThread(thread2)
            XCTAssert(cache.thread(for: thread2.id) == thread2)
            XCTAssert(cache.tids == [thread2.id, thread1.id])
            XCTAssert(cache.thread(for: thread1.id) == thread1)
            XCTAssert(cache.tids == [thread2.id, thread1.id])
            cache.removeThread(thread1)
            XCTAssert(cache.thread(for: thread1.id) == nil)
            XCTAssert(cache.tids == [thread2.id])
            
            cache.setThreads(threads: [thread1, thread2], forFid: 2, typeid: 0)
            let threads = cache.threads(forFid: 2, typeid: 0)!
            XCTAssert(threads == [thread1, thread2])
            cache.setThreads(threads: [thread2, thread1], forFid: 2, typeid: 0)
            let threads2 = cache.threads(forFid: 2, typeid: 0)!
            XCTAssert(threads2 == [thread2, thread1])
            
            let kTotalPageKey = "totalPage"
            let totalPage = 10
            CacheManager.threads.instance?.setObject(totalPage as NSNumber, forKey: kTotalPageKey)
            XCTAssert((CacheManager.threads.instance!.object(forKey: kTotalPageKey) as! NSNumber).intValue == totalPage)
        }
    }
}
