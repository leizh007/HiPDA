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
    var status: UIBindingObserver<Base, DataLoadStatus> {
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

class BaseTableView: UITableView, DataLoadable {
    var refreshHeader: MJRefreshNormalHeader? {
        get {
            return mj_header as? MJRefreshNormalHeader
        }
        
        set {
            mj_header = newValue
        }
    }
    var loadMoreFooter: MJRefreshBackNormalFooter? {
        get {
            return mj_footer as? MJRefreshBackNormalFooter
        }
        
        set {
            mj_footer = newValue
        }
    }
    
    var hasRefreshHeader = false {
        didSet {
            didSetHasRefreshHeader()
        }
    }
    
    var hasLoadMoreFooter = false {
        didSet {
            didSetHasLoadMoreFooter()
        }
    }
    
    weak var dataLoadDelegate: DataLoadDelegate?
    
    var status = DataLoadStatus.loading {
        didSet {
            didSetStatus()
        }
    }
    
    lazy var noResultView: NoResultView = {
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
