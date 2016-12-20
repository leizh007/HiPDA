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

/// BaseTableView的Rx扩展
extension Reactive where Base: BaseTableView {
    var status: UIBindingObserver<Base, BaseTableViewStatus> {
        return UIBindingObserver(UIElement: base) { (tableView, status) in
            tableView.status = status
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

class BaseTableView: UITableView {
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
            bringSubview(toFront: noResultView)
        }
    }
}
