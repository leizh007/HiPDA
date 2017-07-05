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
            return false
        }
    }
    fileprivate var page = 0
    fileprivate var maxPage = 0
    fileprivate var type = SearchType.title
    fileprivate var text = ""
    fileprivate var searchTitleModelsForUI = [SearchTitleModelForUI]()
    var hasMoreData: Bool {
        return page < maxPage
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
        var searchTitleModelsForUI = self.searchTitleModelsForUI
        switch type {
        case .title:
            SearchTitleManager.search(text: text, page: page) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let (totalPage: totalPage, models: models)):
                    DispatchQueue.global().async {
                        let modelsForUI = models.map { model -> SearchTitleModelForUI in
                            let attri = NSMutableAttributedString(string: model.title)
                            for range in model.titleHighlightWordRanges {
                                attri.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: range)
                            }
                            attri.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)],
                                                range: NSRange(location: 0, length: (model.title as NSString).length))
                            let paragraphStye = NSMutableParagraphStyle()
                            paragraphStye.lineBreakMode = .byCharWrapping
                            attri.addAttributes([NSParagraphStyleAttributeName: paragraphStye],
                                                range: NSRange(location: 0, length: (model.title as NSString).length))
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
            SearchFulltextManager.search(text: text, page: page) { [weak self] result in
                guard let `self` = self,
                    `self`.type == type &&
                        `self`.text == text &&
                        `self`.page == page - 1 else { return }
                console(message: String(describing: result))
            }.disposed(by: disposeBag)
        }
    }
}

// MARK: - DataSource

extension SearchViewModel {
    func numberOfItems() -> Int {
        switch type {
        case .title:
            return searchTitleModelsForUI.count
        case .fulltext:
            return 0
        }
    }
    
    func titleModel(at index: Int) -> SearchTitleModelForUI {
        return searchTitleModelsForUI[index]
    }
    
    func tid(at index: Int) -> Int {
        switch type {
        case .title:
            return searchTitleModelsForUI[index].tid
        case .fulltext:
            return 0
        }
    }
}
