//
//  BaseTableView.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

/// BaseTableView的Rx扩展
extension Reactive where Base: BaseTableView {
    /// 状态
    var status: UIBindingObserver<Base, BaseTableViewStatus> {
        return UIBindingObserver(UIElement: base) { (tableView, status) in
            tableView.status = status
        }
    }
    
    /// 是否正在编辑
    var isEditing: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { (tableView, isEditing) in
            tableView.isEditing = isEditing
        }
    }
}

/// Base列表视图的状态
///
/// - normal: 基本状态
/// - noResult: 无数据
/// - tapToLoad: 点击屏幕继续加载
/// - loading: 正在加载
/// - pullDownRefreshing: 下拉刷新中
/// - pullUpLoading: 上拉加载中
enum BaseTableViewStatus {
    case normal
    case noResult
    case tapToLoad
    case loading
    case pullDownRefreshing
    case pullUpLoading
}

protocol TableViewDataLoadDelegate: class {
    func loadNewData()
    func loadMoreData()
}

class BaseTableView: UITableView {
    var hasRefreshHeader = false {
        didSet {
            if hasRefreshHeader {
                let header = MJRefreshNormalHeader { [weak self] _ in
                    self?.status = .pullDownRefreshing
                    self?.dataLoadDelegate?.loadNewData()
                }
                header?.lastUpdatedTimeLabel.isHidden = true
                mj_header = header
            } else {
                mj_header = nil
            }
        }
    }
    
    var hasLoadMoreFooter = false {
        didSet {
            mj_footer = hasLoadMoreFooter ? MJRefreshAutoNormalFooter { [weak self] _ in
                self?.status = .pullUpLoading
                self?.dataLoadDelegate?.loadMoreData()
            } : nil
        }
    }
    
    weak var dataLoadDelegate: TableViewDataLoadDelegate?
    
    /// TableView的状态
    var status = BaseTableViewStatus.loading {
        didSet {
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
                noResultView.removeFromSuperview()
            }
        }
    }
    
    /// noResultView
    private lazy var noResultView: NoResultView = {
        NoResultView.xibInstance
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if noResultView.superview != nil {
            noResultView.frame = bounds
            noResultView.tapToLoadDelegate = self
            bringSubview(toFront: noResultView)
        }
    }
}

// MARK: - TapToLoadDelegate

extension BaseTableView: TapToLoadDelegate {
    func tapToLoad() {
        status = .loading
        dataLoadDelegate?.loadNewData()
    }
}

// MARK: - Data Load

extension BaseTableView {
    func refreshing() {
        mj_header.beginRefreshing()
    }
    
    func endRefreshing() {
        mj_header.endRefreshing()
    }
    
    func loadMore() {
        mj_footer.beginRefreshing()
    }
    
    func endLoadMore() {
        mj_footer.endRefreshing()
    }
    
    func endLoadMoreWithNoMoreData() {
        mj_footer.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        mj_footer.resetNoMoreData()
    }
}
