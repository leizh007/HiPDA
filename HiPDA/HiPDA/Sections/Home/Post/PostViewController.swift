//
//  PostViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import WebKit
import WebViewJavascriptBridge
import MJRefresh

/// 浏览帖子页面
class PostViewController: BaseViewController {
    var postInfo: PostInfo!
    fileprivate var viewModel: PostViewModel!
    fileprivate var webView: BaseWebView!
    fileprivate var bridge: WKWebViewJavascriptBridge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PostViewModel(postInfo: postInfo)
        webView = BaseWebView()
        view.addSubview(webView)
        bridge = WKWebViewJavascriptBridge(for: webView)
        bridge.setWebViewDelegate(self)
        skinWebView(webView)
        skinWebViewJavascriptBridge(bridge)
        loadNewData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let yOffset = C.UI.navigationBarHeight + C.UI.statusBarHeight
        webView.frame = CGRect(x: 0,
                               y: yOffset,
                               width: view.bounds.size.width,
                               height: view.bounds.size.height - yOffset)
    }
    
    fileprivate func updateHeaderAndFooterState() {
        if viewModel.hasMoreData {
            webView.resetNoMoreData()
        } else {
            webView.endLoadMoreWithNoMoreData()
        }
        let states: [MJRefreshState] = [.idle, .pulling, .refreshing]
        for state in states {
            webView.refreshHeader?.setTitle(viewModel.headerTitle(for: state), for: state)
        }
    }
}

// MARK: - Initialization Configure

extension PostViewController {
    fileprivate func skinWebView(_ webView: BaseWebView) {
        webView.hasRefreshHeader = true
        webView.hasLoadMoreFooter = true
        let states: [MJRefreshState] = [.idle, .pulling, .refreshing, .noMoreData]
        for state in states {
            webView.loadMoreFooter?.setTitle(viewModel.footerTitle(for: state), for: state)
        }
        webView.dataLoadDelegate = self
        webView.status = .loading
    }
    
    fileprivate func skinWebViewJavascriptBridge(_ bridge: WKWebViewJavascriptBridge) {
        
    }
}

// MARK: - DataLoadDelegate

extension PostViewController: DataLoadDelegate {
    func loadNewData() {
        viewModel.loadNewData { [weak self] result in
            self?.updateHeaderAndFooterState()
        }
    }
    
    func loadMoreData() {
        viewModel.loadMoreData { [weak self] result in
            self?.updateHeaderAndFooterState()
        }
    }
}

// MARK: - WKNavigationDelegate

extension PostViewController: WKNavigationDelegate {
    
}
