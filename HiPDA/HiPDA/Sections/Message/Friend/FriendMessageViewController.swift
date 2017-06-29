//
//  FriendMessageViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class FriendMessageViewController: MessageTableViewController {
    var friendMessageViewModel: FriendMessageViewModel!
    override var viewModel: MessageTableViewModel! {
        get {
            return friendMessageViewModel
        }
        set {
            friendMessageViewModel = newValue as? FriendMessageViewModel
        }
    }
    
    override func skinViewModel() {
        friendMessageViewModel = FriendMessageViewModel()
    }
    
    override func skinTableView() {
        super.skinTableView()
        tableView.register(FriendMessageTableViewCell.self)
    }
}

extension FriendMessageViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as FriendMessageTableViewCell
        skinCell(cell, at: indexPath.row)
        
        return cell
    }
    
    private func skinCell(_ cell: FriendMessageTableViewCell, at index: Int) {
        cell.separatorInset = .zero
        cell.title = friendMessageViewModel.title(at: index)
        cell.time = friendMessageViewModel.time(at: index)
        cell.isRead = friendMessageViewModel.isRead(at: index)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let user = self.friendMessageViewModel.model(at: indexPath.row).sender
        let vc = UIAlertController(title: "好友消息操作", message: "处理 \(user.name) 发送的好友请求", preferredStyle: .actionSheet)
        let userProfileAction = UIAlertAction(title: "查看 \(user.name) 的资料", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            let vc = UserProfileViewController.load(from: .home)
            vc.uid = user.uid
            self.pushViewController(vc, animated: true)
        }
        let addFriendAction = UIAlertAction(title: "加 \(user.name) 为好友", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.showPromptInformation(of: .loading("正在添加好友..."))
            self.friendMessageViewModel.addFriend(at: indexPath.row) { [weak self] result in
                self?.hidePromptInformation()
                switch result {
                case .success(let info):
                    self?.showPromptInformation(of: .success(info))
                case .failure(let error):
                    self?.showPromptInformation(of: .failure(error.localizedDescription))
                }
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        vc.addAction(userProfileAction)
        vc.addAction(addFriendAction)
        vc.addAction(cancel)
        present(vc, animated: true, completion: nil)
    }
}
