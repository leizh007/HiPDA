//
//  FontAndLineHeightSettingViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import WebKit

class FontAndLineHeightSettingViewController: BaseViewController {
    @IBOutlet fileprivate weak var webViewContainer: UIView!
    fileprivate var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "字体和行间距"
        skinWebView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = webViewContainer.bounds
    }
    
    fileprivate func skinWebView() {
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: 270))
        webView.backgroundColor = .groupTableViewBackground
        webViewContainer.addSubview(webView)
        webView.loadHTMLString(HtmlManager.html(with: content()), baseURL: C.URL.baseWebViewURL)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
    }
    
    fileprivate func content() -> String {
        return "<div class=\"title\" id=\"title\">标题</div><div class=\"post\" id=\"post_1234\" onclick=\"postClicked(this); event.stopPropagation();\"><div class=\"header\"><div class=\"user\" onclick=\"userClicked(this); event.stopPropagation();\"><span><img class=\"avatar\" src=\"https://img02.hi-pda.com/forum/uc_server/data/avatar/000/69/75/58_avatar_middle.jpg\" alt=\"\"/></span><span class=\"username\">leizh007</span><span class=\"uid\">697558</span></div><div class><span class=\"time\">2017-11-11 11:11</span><span class=\"floor\">1#</span></div></div><div class=\"content\">内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容</div></div>"
    }
}
