//
//  DataLoadable.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import MJRefresh

// MARK: - DataLoadStatus

enum DataLoadStatus {
    case normal
    case noResult
    case tapToLoad
    case loading
    case pullDownRefreshing
    case pullUpLoading
}

// MARK: - TapToLoadDelegate

protocol TapToLoadDelegate: class {
    func tapToLoad()
}

// MARK: - DataLoadDelegate

protocol DataLoadDelegate: class {
    func loadNewData()
    func loadMoreData()
}

extension DataLoadDelegate {
    func loadNewData() {}
    func loadMoreData() {}
}

// MARK: - DataLoadable

protocol DataLoadable: TapToLoadDelegate {
    weak var dataLoadDelegate: DataLoadDelegate? { set get }
    var hasRefreshHeader: Bool { set get }
    var hasLoadMoreFooter: Bool { set get }
    var status: DataLoadStatus { set get }
    var noResultView: NoResultView { set get }
    var refreshHeader: MJRefreshNormalHeader? { set get }
    var loadMoreFooter: MJRefreshBackNormalFooter? { set get }
    var isScrollEnabled: Bool { set get }
}

// MARK: - Property didSet

extension DataLoadable where Self: UIView {
    func didSetHasRefreshHeader() {
        if hasRefreshHeader {
            let header = MJRefreshNormalHeader { [weak self] _ in
                self?.status = .pullDownRefreshing
                self?.dataLoadDelegate?.loadNewData()
            }
            header?.lastUpdatedTimeLabel.isHidden = true
            header?.stateLabel.textColor = #colorLiteral(red: 0.3977642059, green: 0.4658440351, blue: 0.5242295265, alpha: 1)
            refreshHeader = header
        } else {
            refreshHeader = nil
        }
    }
    
    func didSetHasLoadMoreFooter() {
        if hasLoadMoreFooter {
            let footer = MJRefreshBackNormalFooter { [weak self] _ in
                self?.status = .pullUpLoading
                self?.dataLoadDelegate?.loadMoreData()
            }
            footer?.stateLabel.textColor = #colorLiteral(red: 0.3977642059, green: 0.4658440351, blue: 0.5242295265, alpha: 1)
            loadMoreFooter = footer
        } else {
            loadMoreFooter = nil
        }
    }
    
    func didSetStatus() {
        switch status {
        case .noResult:
            fallthrough
        case .tapToLoad:
            fallthrough
        case .loading:
            noResultView.status = status
            isScrollEnabled = false
            if noResultView.superview == nil {
                addSubview(noResultView)
            }
        default:
            isScrollEnabled = true
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { 
                self.noResultView.alpha = 0.0
            }, completion: { _ in
                self.noResultView.removeFromSuperview()
                self.noResultView.alpha = 1.0
            })
        }
    }
}

// MARK: - TapToLoadDelegate

extension DataLoadable {
    func tapToLoad() {
        if let delegate = dataLoadDelegate {
            status = .loading
            delegate.loadNewData()
        }
    }
}

// MARK: - Data Load

extension DataLoadable {
    func refreshing() {
        refreshHeader?.beginRefreshing()
    }
    
    func endRefreshing() {
        refreshHeader?.endRefreshing()
    }
    
    func loadMore() {
        loadMoreFooter?.beginRefreshing()
    }
    
    func endLoadMore() {
        loadMoreFooter?.endRefreshing()
    }
    
    func endLoadMoreWithNoMoreData() {
        loadMoreFooter?.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        loadMoreFooter?.resetNoMoreData()
    }
}
