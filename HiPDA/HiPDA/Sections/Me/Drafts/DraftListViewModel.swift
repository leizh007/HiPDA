//
//  DraftListViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/7.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class DraftListViewModel {
    fileprivate let manager = DraftManager.shared
    var hasData: Bool {
        return manager.drafts.count > 0
    }
}

// MARK: - DataSource

extension DraftListViewModel {
    func numberOfModels() -> Int {
        return manager.drafts.count
    }
    
    func model(at index: Int) -> Draft {
        return manager.drafts[index]
    }
    
    func delete(at index: Int) {
        manager.deleteDraft(at: index)
    }
    
    func clear() {
        manager.deleteAllDrafts()
    }
    
    func updateDraft(_ draft: Draft, at index: Int) {
        manager.updateDraft(draft, at: index)
    }
}
