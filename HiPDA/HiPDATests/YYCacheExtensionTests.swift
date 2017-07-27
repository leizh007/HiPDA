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
    let thread1 = HiPDA.Thread(id: 2089676,
                             title: "今天又被查身份证了",
                             attachment: .none,
                             user: User(name: "ttolrats", uid: 681806),
                             postTime: "2017-5-4",
                             replyCount: 22,
                             readCount: 1135)
    let thread2 = HiPDA.Thread(id: 1111111,
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
        guard let cache = CacheManager.threadsReadHistory.shared else {
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
            cache.removeThread(thread1)
            XCTAssert(cache.thread(for: thread1.id) == nil)
            XCTAssert(cache.tids == [thread2.id])
        }
    }
    
    func testThreadsCache() {
        guard let cache = CacheManager.threads.shared else {
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
            CacheManager.threads.shared?.setObject(totalPage as NSNumber, forKey: kTotalPageKey)
            XCTAssert((CacheManager.threads.shared!.object(forKey: kTotalPageKey) as! NSNumber).intValue == totalPage)
        }
    }
    
    func testFriendMessage() {
        let account = Account(name: "leizh007", uid: 123, questionid: 0, answer: "", password: "")
        guard let cache = CacheManager.friendMessage.shared else {
            XCTFail()
            return
        }
        let message1 = FriendMessageModel(isRead: true, sender: User(name: "leizh007", uid: 697558), time: "2017-6-25 22:56")
        let message2 = FriendMessageModel(isRead: true, sender: User(name: "leizh007", uid: 697558), time: "2017-6-26 22:56")
        cache.setMessages([message1, message2], for: account)
        let totalPageKey = "totalPage"
        let lastUpdateTimeKey = "lastUpdateTime"
        cache.setObject(8 as NSNumber, forKey: totalPageKey)
        cache.setObject(22.0 as NSNumber, forKey: lastUpdateTimeKey)
        XCTAssert((cache.messages(for: account) as [FriendMessageModel]?)! == [message1, message2])
        XCTAssert((cache.object(forKey: totalPageKey)! as! NSNumber).intValue == 8)
        XCTAssert((cache.object(forKey: lastUpdateTimeKey)! as! NSNumber).doubleValue == 22.0)
    }
    
    func testThreadMessage() {
        let account = Account(name: "leizh007", uid: 123, questionid: 0, answer: "", password: "")
        guard let cache = CacheManager.threadMessage.shared else {
            XCTFail()
            return
        }
        let message1 = ThreadMessageModel(isRead: true, senderName: "TestAccount", action: "答复了您曾经在主题", postTitle: "测试，请不要回复，谢谢", postAction: "发表的帖子", postURL: "www", time: "2017-6-14 19:12", yourPost: nil, senderPost: "测试")
        let message2 = ThreadMessageModel(isRead: true, senderName: "TestAccount", action: "答复了您曾经在主题", postTitle: "测试，请不要回复，谢谢", postAction: "发表的帖子", postURL: "www", time: "2017-6-14 19:12", yourPost: "测试", senderPost: nil)
        cache.setMessages([message1, message2], for: account)
        XCTAssert((cache.messages(for: account) as [ThreadMessageModel]?)! == [message1, message2])
    }
}
