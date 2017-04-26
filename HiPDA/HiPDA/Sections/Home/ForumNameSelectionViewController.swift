//
//  ForumNameSelectionViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/4/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol ForumNameSelectionDelegate: class {
    func forumNameDidSelected(forumName: String)
}

private let kForumNameCellidentifier = "ForumNameCell"

class ForumNameSelectionViewController: UITableViewController {
    var forumNames = [String]()
    var selectedForumName = ""
    weak var delegate: ForumNameSelectionDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: forumNames.index(of: selectedForumName) ?? 0,
                                            section: 0),
                              at: .middle,
                              animated: false)
    }
}

// MARK: - UITableViewDelegate

extension ForumNameSelectionViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.forumNameDidSelected(forumName: forumNames[indexPath.row])
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: - UITableViewDataSource

extension ForumNameSelectionViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forumNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: kForumNameCellidentifier) ??
            UITableViewCell(style: .default, reuseIdentifier: kForumNameCellidentifier)
        let text = forumNames.safe[indexPath.row] ?? ""
        cell.textLabel?.text = text
        cell.accessoryType = text == selectedForumName ? .checkmark : .none
        cell.tintColor = kNavigationBarTintColor
        
        return cell
    }
}

// MARK: - StoryboardLoadable

extension ForumNameSelectionViewController: StoryboardLoadable {
    
}
