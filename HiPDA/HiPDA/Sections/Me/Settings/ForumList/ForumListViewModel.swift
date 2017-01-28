//
//  ForumListViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/1/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 版块列表选择的view model
struct ForumListViewModel {
    /// 版块列表的section数组
    let sections: Driver<[ForumNameSection]>
    
    // 当前选择的版块列表
    let selectedForumList: Driver<[String]>
    
    init(activeForumList: [String], selection: Driver<IndexPath>) {
        let forumSet = Set<String>(activeForumList)
        
        var forumNameModels = ForumManager.forums.reduce([]) { (result, forum) -> [ForumNameModel] in
            var result = result
            result.append(ForumNameModel(forumName: forum.name, forumDescription: forum.description, level: .first, isChoosed: forumSet.contains(forum.name)))
            guard let subForums = forum.subForums, subForums.count > 0 else { return result }
            for i in 0 ..< (subForums.count - 1) {
                result.append(ForumNameModel(forumName: subForums[i].name, forumDescription: subForums[i].description, level: .secondary, isChoosed: forumSet.contains(subForums[i].name)))
            }
            result.append(ForumNameModel(forumName: subForums.last!.name, forumDescription: subForums.last!.description, level: .secondaryLast, isChoosed: forumSet.contains(subForums.last!.name)))
            return result
        }
        sections = selection.map { indexPath in
            forumNameModels[indexPath.row].isChoosed = !(forumNameModels[indexPath.row].isChoosed)
            return [ForumNameSection(forumList: forumNameModels)]
        }.startWith([ForumNameSection(forumList: forumNameModels)])
        
        selectedForumList = sections.map { sections in
            guard let section = sections.safe[0] else { return [] }
            var selectedForums = [String]()
            for forumNameModel in section.forumList where forumNameModel.isChoosed {
                selectedForums.append(forumNameModel.forumName)
            }
            let selectedForumsSet = Set<String>(selectedForums)
            let oldSelectionForumsSet = forumSet.intersection(selectedForumsSet)
            
            var result = [String]()
            for name in activeForumList where oldSelectionForumsSet.contains(name) {
                result.append(name)
            }
            for name in selectedForums where !oldSelectionForumsSet.contains(name) {
                result.append(name)
            }
            
            return result
        }
    }
}
