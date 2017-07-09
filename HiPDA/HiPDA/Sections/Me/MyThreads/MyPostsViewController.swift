//
//  MyPostsViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import UITableView_FDTemplateLayoutCell

class MyPostsViewController: MyThreadsBaseTableViewController {
    var postsViewModel: MyPostsViewModel!
    override var viewModel: MyThreadsBaseTableViewModel! {
        get {
            return postsViewModel
        }
        set {
            postsViewModel = newValue as? MyPostsViewModel
        }
    }
    
    override func skinViewModel() {
        postsViewModel = MyPostsViewModel()
    }
    
    override func skinTableView() {
        super.skinTableView()
        
        tableView.register(MyPostTableViewCell.self)
    }
}

extension MyPostsViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: MyPostTableViewCell.reuseIdentifier) { [weak self] cell in
            guard let `self` = self, let postCell = cell as? MyPostTableViewCell else { return }
            postCell.model = self.postsViewModel.postModel(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MyPostTableViewCell
        cell.separatorInset = .zero
        cell.model = postsViewModel.postModel(at: indexPath.row)
        return cell
    }
}

