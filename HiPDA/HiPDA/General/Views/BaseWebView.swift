//
//  BaseWebView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import WebKit
import MJRefresh

class BaseWebView: WKWebView, DataLoadable {
    var isScrollEnabled: Bool {
        get {
            return scrollView.isScrollEnabled
        }
        
        set {
            scrollView.isScrollEnabled = newValue
        }
    }
    var refreshHeader: MJRefreshHeader? {
        get {
            return scrollView.mj_header
        }
        
        set {
            scrollView.mj_header = newValue
        }
    }
    var loadMoreFooter: MJRefreshFooter? {
        get {
            return scrollView.mj_footer
        }
        
        set {
            scrollView.mj_footer = newValue
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
