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
import MLeaksFinder

/// 浏览帖子页面
class PostViewController: BaseViewController {
    static func getInstance() -> PostViewController {
        return PostViewController.shared.parent == nil ? PostViewController.shared : PostViewController.load(from: .home)
    }
    
    fileprivate static let shared = PostViewController.load(from: .home)
    
    var postInfo: PostInfo! {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModel.postInfo = postInfo
            dataOutDated = true
        }
    }
    
    fileprivate var dataOutDated = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataOutDated {
            webView.status = .loading
            loadNewData()
            dataOutDated = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let yOffset = C.UI.navigationBarHeight + C.UI.statusBarHeight
        webView.frame = CGRect(x: 0,
                               y: yOffset,
                               width: view.bounds.size.width,
                               height: view.bounds.size.height - yOffset)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        guard parent == nil else { return }
        
        webView.loadHTMLString(viewModel.emptyHtml, baseURL: C.URL.baseURL)
    }
    
    override func willDealloc() -> Bool {
        return false
    }
    
    fileprivate func updateWebViewState() {
        let states: [MJRefreshState] = [.idle, .pulling, .refreshing]
        for state in states {
            webView.refreshHeader?.setTitle(viewModel.headerTitle(for: state), for: state)
        }
    }
    
    fileprivate func animationOptions(of status: PostViewStatus) -> UIViewAnimationOptions {
        switch status {
        case .loadingFirstPage:
            return [.allowAnimatedContent, .transitionCrossDissolve]
        case .loadingPreviousPage:
            return [.transitionCurlDown, .allowAnimatedContent]
        case .loadingNextPage:
            return [.transitionCurlUp, .allowAnimatedContent]
        default:
            return [.allowAnimatedContent, .transitionCrossDissolve]
        }
    }
    
    fileprivate func  handleDataLoadResult(_ result: PostResult) {
        switch result {
        case .success(let html):
            if viewModel.hasData {
                let options = animationOptions(of: viewModel.status)
                UIView.transition(with: webView, duration: C.UI.animationDuration * 4.0, options: options, animations: {
                    self.webView.loadHTMLString(html, baseURL: C.URL.baseURL)
                }, completion: { _ in
                    self.configureWebViewAfterLoadData()
                })
            } else {
                webView.endRefreshing()
                webView.endLoadMore()
                webView.status = .noResult
                viewModel.status = .idle
            }
        case .failure(let error):
            showPromptInformation(of: .failure("\(error)"))
            viewModel.status = .idle
            if webView.status == .loading {
                webView.status = .tapToLoad
            } else {
                webView.endRefreshing()
                webView.endLoadMore()
            }
        }
    }
    
    fileprivate func configureWebViewAfterLoadData() {
        if webView.status == .pullUpLoading {
            if viewModel.hasMoreData {
                webView.endLoadMore()
                webView.resetNoMoreData()
            } else {
                webView.endLoadMoreWithNoMoreData()
            }
        } else if webView.status ==  .pullDownRefreshing {
            webView.endRefreshing()
            if viewModel.hasMoreData {
                webView.resetNoMoreData()
            } else {
                webView.endLoadMoreWithNoMoreData()
            }
        } else {
            if viewModel.hasMoreData {
                webView.resetNoMoreData()
            } else {
                webView.endLoadMoreWithNoMoreData()
            }
        }
        webView.status = .normal
        viewModel.status = .idle
    }
}

// MARK: - Initialization Configure

extension PostViewController {
    fileprivate func skinWebView(_ webView: BaseWebView) {
        webView.hasRefreshHeader = true
        webView.hasLoadMoreFooter = true
        webView.scrollView.delegate = self
        webView.allowsLinkPreview = false
        webView.uiDelegate = self
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
        let date = Date()
        viewModel.loadNewData { [weak self] result in
            self?.updateWebViewState()
            self?.handleDataLoadResult(result)
            console(message: "\(Date().timeIntervalSince(date))")
        }
    }
    
    func loadMoreData() {
        viewModel.loadMoreData { [weak self] result in
            self?.updateWebViewState()
            self?.handleDataLoadResult(result)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PostViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

// MARK: - WKNavigationDelegate

extension PostViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        webView.scrollView.backgroundColor = .groupTableViewBackground
//        guard let webView = webView as? BaseWebView else { return }
//        if webView.status == .pullUpLoading {
//            if viewModel.hasMoreData {
//                webView.endLoadMore()
//                webView.resetNoMoreData()
//            } else {
//                webView.endLoadMoreWithNoMoreData()
//            }
//        } else if webView.status ==  .pullDownRefreshing {
//            webView.endRefreshing()
//            if viewModel.hasMoreData {
//                webView.resetNoMoreData()
//            } else {
//                webView.endLoadMoreWithNoMoreData()
//            }
//        } else {
//            if viewModel.hasMoreData {
//                webView.resetNoMoreData()
//            } else {
//                webView.endLoadMoreWithNoMoreData()
//            }
//        }
//        webView.status = .normal
//        viewModel.status = .idle
//    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.scrollView.backgroundColor = .groupTableViewBackground
//        guard let webView = webView as? BaseWebView else { return }
//        if webView.status == .pullUpLoading {
//            if viewModel.hasMoreData {
//                webView.endLoadMore()
//                webView.resetNoMoreData()
//            } else {
//                webView.endLoadMoreWithNoMoreData()
//            }
//        } else if webView.status ==  .pullDownRefreshing {
//            webView.endRefreshing()
//            if viewModel.hasMoreData {
//                webView.resetNoMoreData()
//            } else {
//                webView.endLoadMoreWithNoMoreData()
//            }
//        } else {
//            if viewModel.hasMoreData {
//                webView.resetNoMoreData()
//            } else {
//                webView.endLoadMoreWithNoMoreData()
//            }
//        }
//        webView.status = .normal
//        viewModel.status = .idle
//    }
}

// MARK: - WKUIDelegate

extension PostViewController: WKUIDelegate {
    @available(iOS 10.0, *)
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
}

// MARK: - StoryboardLoadable

extension PostViewController: StoryboardLoadable {}
