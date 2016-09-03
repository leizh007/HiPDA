//
//  CollectionType+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

struct SafeCollection<Base: Collection> {
    private var _base: Base
    init(_ base: Base) {
        _base = base
    }
    
    typealias Index = Base.Index
    var startIndex: Index {
        return _base.startIndex
    }
    var endIndex: Index {
        return _base.endIndex
    }
    
    func index(after i: Base.Index) -> Base.Index {
        return _base.index(after: i)
    }
    
    subscript(index: Base.Index) -> Base.Iterator.Element? {
        if _base.distance(from: startIndex, to: index) >= 0 && _base.distance(from: index, to: endIndex) > 0 {
            return self._base[index]
        }
        
        return nil
    }
    
    subscript(bounds: Range<Base.Index>) -> Base.SubSequence? {
        if _base.distance(from: startIndex, to: bounds.lowerBound) >= 0 && _base.distance(from: bounds.upperBound, to: endIndex) >= 0 {
            return self._base[bounds]
        }
        return nil
    }
    
    var safe: SafeCollection<Base> { //Allows to chain ".safe" without side effects
        return self
    }
}

extension Collection {
    var safe: SafeCollection<Self> {
        return SafeCollection(self)
    }
}
