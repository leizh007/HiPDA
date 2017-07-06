//
//  SearchViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import UITableView_FDTemplateLayoutCell

/// 搜索的ViewController
class SearchViewController: BaseViewController {
    @IBOutlet fileprivate var titleView: UIView!
    @IBOutlet fileprivate weak var segmentControlContainerView: UIView!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var segmentControl: UISegmentedControl!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    fileprivate let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureApperance()
        skinTableView(tableView)
        NotificationCenter.default.addObserver(self, selector: #selector(searchViewControllerTabRepeatedSelected), name: .SearchViewControllerTabRepeatedSelected, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func searchViewControllerTabRepeatedSelected() {
        tableView.setContentOffset(.zero, animated: true)
    }
    
    func configureApperance() {
        titleView.frame = CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: 44.0)
        navigationItem.titleView = titleView
        
        segmentControlContainerView.layer.shadowOffset = CGSize(width: 0, height: CGFloat.from(pixel: 1))
        segmentControlContainerView.layer.shadowRadius = 0
        segmentControlContainerView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        segmentControlContainerView.layer.shadowOpacity = 0.25
    }
    
    @IBAction fileprivate func cancelButtonDidPressed(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        viewModel.clear()
        tableView.reloadData()
        tableView.isScrollEnabled = false
        tableView.status = .normal
    }
    
    @IBAction fileprivate func segmentControlValueChanged(_ sender: UISegmentedControl) {
        if !searchBar.isFirstResponder {
            search()
        }
    }
    
    fileprivate func skinTableView(_ tableView: BaseTableView) {
        tableView.hasRefreshHeader = false
        tableView.hasLoadMoreFooter = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
    }
    
    fileprivate func search() {
        guard let type = SearchType(rawValue: segmentControl.selectedSegmentIndex),
            let text = searchBar.text, !text.isEmpty else { return }
        tableView.endLoadMore()
        tableView.resetNoMoreData()
        tableView.status = .loading
        viewModel.search(type: type, text: text) { [weak self] result in
            guard let `self` = self else { return }
            self.tableView.isScrollEnabled = true
            self.tableView.setContentOffset(.zero, animated: false)
            self.tableView.reloadData()
            if case .failure(let error) = result {
                self.showPromptInformation(of: .failure(error.localizedDescription))
                self.tableView.status = .tapToLoad
            } else {
                self.tableView.status = self.viewModel.hasData ? .normal : .noResult
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let type = SearchType(rawValue: segmentControl.selectedSegmentIndex) else { return 44.0 }
        switch type {
        case .title:
            return tableView.fd_heightForCell(withIdentifier: SearchTitleTableViewCell.reuseIdentifier) { [unowned self] cell in
                guard let titleCell = cell as? SearchTitleTableViewCell else { return }
                let model = self.viewModel.titleModel(at: indexPath.row)
                titleCell.model = model
            }
        default:
            return tableView.fd_heightForCell(withIdentifier: SearchFulltextTableViewCell.reuseIdentifier) { [unowned self] cell in
                guard let fulltextCell = cell as? SearchFulltextTableViewCell else { return }
                fulltextCell.model = self.viewModel.fulltextModel(at: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        URLDispatchManager.shared.linkActived(viewModel.jumURL(at: indexPath.row))
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = SearchType(rawValue: segmentControl.selectedSegmentIndex) else {
            fatalError()
        }
        switch type {
        case .title:
            let cell = tableView.dequeueReusableCell(for: indexPath) as SearchTitleTableViewCell
            cell.model = viewModel.titleModel(at: indexPath.row)
            return cell
        case .fulltext:
            let cell = tableView.dequeueReusableCell(for: indexPath) as SearchFulltextTableViewCell
            cell.model = viewModel.fulltextModel(at: indexPath.row)
            return cell
        }
    }
}

// MARK: - DataLoadDelegate

extension SearchViewController: DataLoadDelegate {
    func loadMoreData() {
        viewModel.loadMoreData { [weak self] result in
            guard let `self` = self else { return }
            self.tableView.reloadData()
            if self.viewModel.hasMoreData {
                self.tableView.endLoadMore()
            } else {
                self.tableView.endLoadMoreWithNoMoreData()
            }
            if case .failure(let error) = result {
                self.showPromptInformation(of: .failure(error.localizedDescription))
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
}
