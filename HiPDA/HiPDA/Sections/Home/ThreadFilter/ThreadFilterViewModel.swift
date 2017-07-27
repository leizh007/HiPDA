//
//  ThreadFilterViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class ThreadFilterViewModel {
    fileprivate var sections: [FilterSection]
    init(sections: [FilterSection]) {
        self.sections = sections
    }
}

extension ThreadFilterViewModel {
    func numberOfSections() -> Int {
        return  sections.count
    }
    
    func numberOfItems(in index: Int) -> Int {
        return sections[index].isCollapsed ? 0 : sections[index].items.count
    }
    
    func sectionHeader(at index: Int) -> String {
        return "\(sections[index].header):"
    }
    
    func sectionSubTitle(at index: Int) -> String {
        return sections[index].items[sections[index].selectedIndex]
    }
    
    func changeSectionHeaderCollapse(at index: Int) {
        sections[index].isCollapsed = !sections[index].isCollapsed
    }
    
    func title(at indexPath: IndexPath) -> String {
        return sections[indexPath.section].items[indexPath.row]
    }
    
    func selectedItemIndex(at section: Int) -> Int {
        return sections[section].selectedIndex
    }
    
    func selecteItem(at indexPath: IndexPath) {
        sections[indexPath.section].selectedIndex = indexPath.row
    }
}
