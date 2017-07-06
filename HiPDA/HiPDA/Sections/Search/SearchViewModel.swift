//
//  SearchViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/4.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

enum SearchType: Int {
    case title = 0
    case fulltext
}

extension SearchType: CustomStringConvertible {
    var description: String {
        switch self {
        case .title:
            return "title"
        case .fulltext:
            return "fulltext"
        }
    }
}

class SearchViewModel {
    fileprivate var disposeBag = DisposeBag()
    var hasData: Bool {
        switch type {
        case .title:
            return searchTitleModelsForUI.count > 0
        case .fulltext:
            return searchFulltextModelsForUI.count > 0
        }
    }
    fileprivate var page = 0
    fileprivate var maxPage = 0
    fileprivate var type = SearchType.title
    fileprivate var text = ""
    fileprivate var searchTitleModelsForUI = [SearchTitleModelForUI]()
    fileprivate var searchFulltextModelsForUI = [SearchFulltextModelForUI]()
    var hasMoreData: Bool {
        return page < maxPage
    }
    
    func clear() {
        page = 0
        maxPage = 0
        searchTitleModelsForUI = []
        searchFulltextModelsForUI = []
    }
    
    func search(type: SearchType, text: String, completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        self.page = 0
        self.type = type
        self.text = text
        search(type: type, text: text, page: page + 1, completion: completion)
    }
    
    func loadMoreData(completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        search(type: type, text: text, page: page + 1, completion: completion)
    }
    
    fileprivate func search(type: SearchType, text: String, page: Int, completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        disposeBag = DisposeBag()
        switch type {
        case .title:
            var searchTitleModelsForUI = self.searchTitleModelsForUI
            SearchTitleManager.search(text: text, page: page) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let (totalPage: totalPage, models: models)):
                    DispatchQueue.global().async {
                        let modelsForUI = models.map { model -> SearchTitleModelForUI in
                            let attri = SearchViewModel.attributedString(from: model.title, fontSize: 17.0, ranges: model.titleHighlightWordRanges)
                            return SearchTitleModelForUI(tid: model.tid, title: attri, forumName: model.forumName, user: model.user, time: model.time, readCount: model.readCount, replyCount: model.replyCount)
                        }
                        if page == 1 {
                            searchTitleModelsForUI = modelsForUI
                        } else {
                            searchTitleModelsForUI.append(contentsOf: modelsForUI)
                        }
                        DispatchQueue.main.async {
                            guard self.type == type &&
                                self.text == text &&
                                self.page == page - 1 else { return }
                            self.page = page
                            self.maxPage = totalPage
                            self.searchTitleModelsForUI = searchTitleModelsForUI
                            completion(.success(()))
                        }
                    }
                }
            }.disposed(by: disposeBag)
        case .fulltext:
            var searchFulltextModelsForUI = self.searchFulltextModelsForUI
            SearchFulltextManager.search(text: text, page: page) { [weak self] result in
                guard let `self` = self  else { return }
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let (totalPage: totalPage, models: models)):
                    DispatchQueue.global().async {
                        let modelsForUI = models.map { model -> SearchFulltextModelForUI in
                            let attri = SearchViewModel.attributedString(from: model.content, fontSize: 16.0, ranges: model.contentHighlightWordRanges)
                            return SearchFulltextModelForUI(pid: model.pid, title: model.title, content: attri, forumName: model.forumName, user: model.user, readCount: model.readCount, replyCount: model.readCount, time: model.time)
                        }
                        if page == 1 {
                            searchFulltextModelsForUI = modelsForUI
                        } else {
                            searchFulltextModelsForUI.append(contentsOf: modelsForUI)
                        }

                        DispatchQueue.main.async {
                            guard self.type == type &&
                                self.text == text &&
                                self.page == page - 1 else { return }
                            self.page = page
                            self.maxPage = totalPage
                            self.searchFulltextModelsForUI = searchFulltextModelsForUI
                            completion(.success(()))
                        }
                    }
                }
            }.disposed(by: disposeBag)
        }
    }
    
    fileprivate static func attributedString(from content: String, fontSize: CGFloat, ranges: [NSRange]) -> NSAttributedString {
        let attri = NSMutableAttributedString(string: content)
        for range in ranges {
            attri.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: range)
        }
        let fullRange = NSRange(location: 0, length: (content as NSString).length)
        attri.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], range: fullRange)
        let paragraphStye = NSMutableParagraphStyle()
        paragraphStye.lineBreakMode = .byCharWrapping
        attri.addAttributes([NSParagraphStyleAttributeName: paragraphStye], range: fullRange)
        
        return attri
    }
}

// MARK: - DataSource

extension SearchViewModel {
    func numberOfItems() -> Int {
        switch type {
        case .title:
            return searchTitleModelsForUI.count
        case .fulltext:
            return searchFulltextModelsForUI.count
        }
    }
    
    func titleModel(at index: Int) -> SearchTitleModelForUI {
        return searchTitleModelsForUI[index]
    }
    
    func fulltextMoel(at index: Int) -> SearchFulltextModelForUI {
        return searchFulltextModelsForUI[index]
    }
    
    func jumURL(at index: Int) -> String {
        switch type {
        case .title:
            return "https://www.hi-pda.com/forum/viewthread.php?tid=\(searchTitleModelsForUI[index].tid)&highlight="
        case .fulltext:
            return "https://www.hi-pda.com/forum/redirect.php?goto=findpost&pid=\(searchFulltextModelsForUI[index].pid)"
        }
    }
}
