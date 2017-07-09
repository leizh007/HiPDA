//
//  MyTopicsViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class MyTopicsViewModel: MyThreadsBaseTableViewModel {
    var topicModels = [MyTopicModel]()
    override var models: [MyThreadsBaseModel] {
        get {
            return topicModels
        }
        set {
            topicModels = newValue as? [MyTopicModel] ?? []
        }
    }
    
    override func api(at page: Int) -> HiPDA.API {
        return .myTopics(page: page)
    }
    
    override func transform(html: String) throws -> [MyThreadsBaseModel] {
        return try HtmlParser.myTopicModels(from: html)
    }
    
    override func jumpURL(at index: Int) -> String {
        return "https://www.hi-pda.com/forum/viewthread.php?tid=\(topicModel(at: index).tid)&extra=page%3D1"
    }
}

extension MyTopicsViewModel {
    func topicModel(at index: Int) -> MyTopicModel {
        return topicModels[index]
    }
}
