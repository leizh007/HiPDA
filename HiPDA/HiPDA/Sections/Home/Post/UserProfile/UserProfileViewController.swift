//
//  UerProfileViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    var uid: Int!
    fileprivate var viewModel: UserProfileViewModel!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "个人资料"
        viewModel = UserProfileViewModel(uid: uid)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.hasLoadMoreFooter = false
        tableView.status = .loading
        loadNewData()
    }
}

// MARK: - UITableViewDelegate

extension UserProfileViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension UserProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: "a")
    }
}

extension UserProfileViewController: DataLoadDelegate {
    func loadNewData() {
        viewModel.refresh { [weak self] result in
            guard let `self` = self else { return }
            self.tableView.endRefreshing()
            switch result {
            case .success(_):
                self.tableView.status = .normal
                self.tableView.reloadData()
            case .failure(let error):
                self.showPromptInformation(of: .failure(error.localizedDescription))
                if self.tableView.status == .loading {
                    self.tableView.status = .tapToLoad
                } else {
                    self.tableView.status = .normal
                }
            }
        }
    }
}

// MARK: - StoryboardLoadable

extension UserProfileViewController: StoryboardLoadable { }
