//
//  ThreadFilterViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class ThreadFilterViewController: BaseViewController {
    var filterSections: [FilterSection]!
    var selectedCompletion: ((ThreadFilter) -> Void)?
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    fileprivate var viewModel: ThreadFilterViewModel!
    @IBOutlet var seperatorHeightConstraints: [NSLayoutConstraint]!
    fileprivate var sectionHeaders = [Int: ThreadFilterSectionHeaderView]()
    fileprivate var sectionFooters = [Int: UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinViewModel()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        for constraint in seperatorHeightConstraints {
            constraint.constant = 1.0 / C.UI.screenScale
        }
    }
    
    fileprivate func skinViewModel() {
        viewModel = ThreadFilterViewModel(sections: filterSections)
    }
    
    @IBAction fileprivate func selectButtonPressed(_ sender: Any) {
        let typeName = viewModel.title(at: IndexPath(row: viewModel.selectedItemIndex(at: 0), section: 0))
        let order = ThreadOrder.order(from: viewModel.title(at: IndexPath(row: viewModel.selectedItemIndex(at: 1), section: 1))) ?? .lastpost
        selectedCompletion?(ThreadFilter(typeName: typeName, order: order))
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ThreadFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0 / C.UI.screenScale
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView: UIView
        if let view = sectionFooters[section] {
            footerView = view
        } else {
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: 1.0 / C.UI.screenScale))
            footerView.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: ThreadFilterSectionHeaderView
        if let view = sectionHeaders[section] {
            headerView = view
        } else {
            headerView = Bundle.main.loadNibNamed("ThreadFilterSectionHeaderView",
                                                  owner: self,
                                                  options: nil)!.first! as! ThreadFilterSectionHeaderView
            sectionHeaders[section] = headerView
            headerView.delegate = self
            headerView.tag = section
        }
        headerView.title = viewModel.sectionHeader(at: section)
        headerView.subTitle = viewModel.sectionSubTitle(at: section)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let oldCell = tableView.cellForRow(at: IndexPath(row: viewModel.selectedItemIndex(at: indexPath.section), section: indexPath.section)) as? ThreadFilterTableViewCell {
            oldCell.isItemSelected = false
        }
        viewModel.selecteItem(at: indexPath)
        if let newCell = tableView.cellForRow(at: IndexPath(row: viewModel.selectedItemIndex(at: indexPath.section), section: indexPath.section)) as? ThreadFilterTableViewCell {
            newCell.isItemSelected = true
        }
        let headerView = sectionHeaders[indexPath.section]!
        headerView.title = viewModel.sectionHeader(at: indexPath.section)
        headerView.subTitle = viewModel.sectionSubTitle(at: indexPath.section)
    }
}

extension ThreadFilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as ThreadFilterTableViewCell
        cell.title = viewModel.title(at: indexPath)
        cell.isItemSelected = viewModel.selectedItemIndex(at: indexPath.section) == indexPath.row
        
        return cell
    }
}

extension ThreadFilterViewController: ThreadFilterSectionHeaderDelegate {
    func sectionHeaderDidTapped(_ sectionHeader: ThreadFilterSectionHeaderView) {
        viewModel.changeSectionHeaderCollapse(at: sectionHeader.tag)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableView.reloadData()
        }
        tableView.reloadSections(IndexSet(integer: sectionHeader.tag), with: .automatic)
        CATransaction.commit()
    }
}

extension ThreadFilterViewController: StoryboardLoadable { }
