//
//  DraftManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/7.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class DraftManager {
    static let shared = DraftManager()
    fileprivate let cache = CacheManager.draft.shared!
    lazy var drafts: [Draft] = {
        return CacheManager.draft.shared!.drafts()
    }()
    
    func deleteDraft(at index: Int) {
        guard index >= 0 && index < drafts.count else { return }
        drafts.remove(at: index)
        cache.setDrafts(drafts)
    }
    
    func deleteAllDrafts() {
        drafts = []
        cache.setDrafts([])
    }
    
    func updateDraft(_ draft: Draft, at index: Int) {
        drafts[index] = draft
        cache.setDrafts(drafts)
    }
    
    func addDraft(_ draft: Draft) {
        drafts.append(draft)
        cache.setDrafts(drafts)
    }
}
