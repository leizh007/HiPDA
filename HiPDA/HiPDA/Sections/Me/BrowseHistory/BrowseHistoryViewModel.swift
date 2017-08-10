//
//  BrowseHistoryViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import YYCache

class BrowseHistoryViewModel {
    fileprivate var cache: YYCache? = nil
    fileprivate var threads: [HiPDA.Thread] = []
    fileprivate var models = [HomeThreadModel]()
    
    func loadData(completion: @escaping (Void) -> Void) {
        DispatchQueue.global().async {
            let cache = CacheManager.threadsReadHistory.shared
            self.cache = cache
            let threads = cache?.tids.flatMap { cache?.thread(for: $0) } ?? []
            self.models = threads.map(threadModel(from:))
            self.threads = threads
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    var hasData: Bool {
        return threads.count > 0
    }
}

extension BrowseHistoryViewModel {
    func read(at index: Int) {
        cache?.addThread(threads[index])
        threads.insert(threads.remove(at: index), at: 0)
        models.insert(models.remove(at: index), at: 0)
    }
    
    func delete(at index: Int) {
        cache?.removeThread(threads[index])
        threads.remove(at: index)
        models.remove(at: index)
    }
    
    func clear() {
        cache?.clear()
        threads = []
        models = []
    }
    
    func numberOfModels() -> Int {
        return threads.count
    }
    
    func model(at index: Int) -> HomeThreadModel {
        return models[index]
    }
    
    func tid(at index: Int) -> Int {
        return threads[index].id
    }
}
