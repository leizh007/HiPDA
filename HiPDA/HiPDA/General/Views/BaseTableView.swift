//
//  BaseTableView.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

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
