//
//  EditWordListTableViewStateTests.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/14.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import XCTest
@testable import HiPDA

class EditWordListTableViewStateTests: XCTestCase {
    lazy var state: EditWordListTableViewState = {
        let section1 = EditWordListSection(words: ["1", "2"])
        let section2 = EditWordListSection(words: ["3", "4", "5", "6"])
        let section3 = EditWordListSection(words: ["7", "8", "9"])
        return EditWordListTableViewState(sections: [section1, section2, section3])
    }()
    
    lazy var state1: EditWordListTableViewState = {
        let section1 = EditWordListSection(words: ["1", "2", "10"])
        let section2 = EditWordListSection(words: ["3", "4", "5", "6"])
        let section3 = EditWordListSection(words: ["7", "8", "9"])
        return EditWordListTableViewState(sections: [section1, section2, section3])
    }()
    
    lazy var state2: EditWordListTableViewState = {
        let section1 = EditWordListSection(words: ["1", "2", "10"])
        let section2 = EditWordListSection(words: ["3", "5", "6"])
        let section3 = EditWordListSection(words: ["7", "8", "9"])
        return EditWordListTableViewState(sections: [section1, section2, section3])
    }()
    
    lazy var state3: EditWordListTableViewState = {
        let section1 = EditWordListSection(words: ["1", "2", "10"])
        let section2 = EditWordListSection(words: ["3", "5", "6"])
        let section3 = EditWordListSection(words: ["8", "9", "7"])
        return EditWordListTableViewState(sections: [section1, section2, section3])
    }()
    
    lazy var state4: EditWordListTableViewState = {
        let section1 = EditWordListSection(words: ["1", "2", "9", "10"])
        let section2 = EditWordListSection(words: ["3", "5", "6"])
        let section3 = EditWordListSection(words: ["8", "7"])
        return EditWordListTableViewState(sections: [section1, section2, section3])
    }()
    
    lazy var state5: EditWordListTableViewState = {
        let section1 = EditWordListSection(words: ["1"])
        let section2 = EditWordListSection(words: ["3", "5", "6"])
        let section3 = EditWordListSection(words: ["8", "7"])
        return EditWordListTableViewState(sections: [section1, section2, section3])
    }()
    
    func testStateCommands() {
        let addCommand = EditWordListTableViewEditingCommand.append("10", in: 0)
        let state1 = self.state.execute(addCommand)
        XCTAssert(state1 == self.state1)
        
        let deleteCommand = EditWordListTableViewEditingCommand.delete(with: IndexPath(row: 1, section: 1))
        let state2 = state1.execute(deleteCommand)
        XCTAssert(state2 == self.state2)
        
        let moveCommand1 = EditWordListTableViewEditingCommand.move(from: IndexPath(row: 0, section: 2), to: IndexPath(row: 2, section: 2))
        let state3 = state2.execute(moveCommand1)
        XCTAssert(state3 == self.state3)
        
        let moveCommand2 = EditWordListTableViewEditingCommand.move(from: IndexPath(row: 1, section: 2), to: IndexPath(row: 2, section: 0))
        let state4 = state3.execute(moveCommand2)
        XCTAssert(state4 == self.state4)
        
        let replaceCommand = EditWordListTableViewEditingCommand.replace(self.state5)
        let state5 = state4.execute(replaceCommand)
        XCTAssert(state5 == self.state5)
    }
}
