//
//  MyPostsViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class MyPostsViewModel: MyThreadsBaseTableViewModel {
    var postModels = [MyPostModel]()
    override var models: [MyThreadsBaseModel] {
        get {
            return postModels
        }
        set {
            postModels = newValue as? [MyPostModel] ?? []
        }
    }
    
    override func api(at page: Int) -> HiPDA.API {
        return .myPosts(page: page)
    }
    
    override func transform(html: String) throws -> [MyThreadsBaseModel] {
        return try HtmlParser.myPostModels(from: html)
    }
    
    override func jumpURL(at index: Int) -> String {
        return "https://www.hi-pda.com/forum/\(postModel(at: index).urlPath)"
    }
}

extension MyPostsViewModel {
    func postModel(at index: Int) -> MyPostModel {
        return postModels[index]
    }
}
