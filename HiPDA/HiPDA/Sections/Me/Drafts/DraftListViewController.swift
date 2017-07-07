//
//  DraftListViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/6.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import UITableView_FDTemplateLayoutCell

class DraftListViewController: BaseViewController {
    fileprivate let viewModel = DraftListViewModel()
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "草稿箱"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        tableView.status = viewModel.hasData ? .normal : .noResult
    }
}

// MARK: - UITableViewDelegateu xi

extension DraftListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.fd_heightForCell(withIdentifier: DraftTableViewCell.reuseIdentifier) { [unowned self] cell in
            guard let draftCell = cell as? DraftTableViewCell else { return }
            draftCell.model = self.viewModel.model(at: indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource

extension DraftListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfModels()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as DraftTableViewCell
        cell.model = viewModel.model(at: indexPath.row)
        
        return cell
    }
}
