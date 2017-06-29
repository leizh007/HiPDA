//
//  ThreadMessageViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import UITableView_FDTemplateLayoutCell

class ThreadMessageViewController: MessageTableViewController {
    var threadMessageViewModel: ThreadMessageViewModel!
    override var viewModel: MessageTableViewModel! {
        get {
            return threadMessageViewModel
        }
        set {
            threadMessageViewModel = newValue as? ThreadMessageViewModel
        }
    }
    
    override func skinViewModel() {
        threadMessageViewModel = ThreadMessageViewModel()
    }
    
    override func skinTableView() {
        super.skinTableView()
        tableView.register(ThreadMessageTableViewCell.self)
    }
}

extension ThreadMessageViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as ThreadMessageTableViewCell
        skinCell(cell, at: indexPath.row)
        cell.update()
        
        return cell
    }
    
    private func skinCell(_ cell: ThreadMessageTableViewCell, at index: Int) {
        cell.separatorInset = .zero
        cell.title = threadMessageViewModel.title(at: index)
        cell.yourPost = threadMessageViewModel.yourPost(at: index)
        cell.senderPost = threadMessageViewModel.senderPost(at: index)
        cell.isRead = threadMessageViewModel.isRead(at: index)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: ThreadMessageTableViewCell.reuseIdentifier, configuration: { [weak self] cell in
            guard let messageCell = cell as? ThreadMessageTableViewCell else { return }
            messageCell.fd_enforceFrameLayout = true
            self?.skinCell(messageCell, at: indexPath.row)
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        URLDispatchManager.shared.linkActived(threadMessageViewModel.postURL(at: indexPath.row))
    }
}
