//
//  PrivateMessageViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/30.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class PrivateMessageViewController: MessageTableViewController {
    var privateMessageViewModel: PrivateMessageViewModel!
    override var viewModel: MessageTableViewModel! {
        get {
            return privateMessageViewModel
        }
        set {
            privateMessageViewModel = newValue as? PrivateMessageViewModel
        }
    }
    
    override func skinViewModel() {
        privateMessageViewModel = PrivateMessageViewModel()
    }
    
    override func skinTableView() {
        super.skinTableView()
        tableView.register(PrivateMessageTableViewCell.self)
    }
}

extension PrivateMessageViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as PrivateMessageTableViewCell
        skinCell(cell, at: indexPath.row)
        
        return cell
    }
    
    private func skinCell(_ cell: PrivateMessageTableViewCell, at index: Int) {
        cell.separatorInset = .zero
        cell.user = privateMessageViewModel.user(at: index)
        cell.content = privateMessageViewModel.content(at: index)
        cell.time = privateMessageViewModel.time(at: index)
        cell.isRead = privateMessageViewModel.isRead(at: index)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let vc = ChatViewController()
        vc.user = privateMessageViewModel.user(at: indexPath.row)
        vc.hidesBottomBarWhenPushed = true
        pushViewController(vc, animated: true)
    }
}
