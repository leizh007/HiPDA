//
//  MyTopicsViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import UITableView_FDTemplateLayoutCell

class MyTopicsViewController: MyThreadsBaseTableViewController {
    var topicsViewModel: MyTopicsViewModel!
    override var viewModel: MyThreadsBaseTableViewModel! {
        get {
            return topicsViewModel
        }
        set {
            topicsViewModel = newValue as? MyTopicsViewModel
        }
    }
    
    override func skinViewModel() {
        topicsViewModel = MyTopicsViewModel()
    }
    
    override func skinTableView() {
        super.skinTableView()
        
        tableView.register(MyTopicTableViewCell.self)
    }
}

extension MyTopicsViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: MyTopicTableViewCell.reuseIdentifier) { [weak self] cell in
            guard let `self` = self, let topicCell = cell as? MyTopicTableViewCell else { return }
            topicCell.model = self.topicsViewModel.topicModel(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MyTopicTableViewCell
        cell.separatorInset = .zero
        cell.model = topicsViewModel.topicModel(at: indexPath.row)
        return cell
    }
}
