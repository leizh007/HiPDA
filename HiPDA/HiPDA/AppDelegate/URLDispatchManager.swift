//
//  URLDispatchManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/3.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import SafariServices

class URLDispatchManager: NSObject {
    static let shared = URLDispatchManager()
    var shouldHandlePasteBoardChanged = true
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(userDidCopiedContentToPasteBoard(_:)), name:
            .UIPasteboardChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var topVC: UIViewController? {
        return UIApplication.topViewController()
    }
    
    func userDidCopiedContentToPasteBoard(_ notification: NSNotification) {
        guard shouldHandlePasteBoardChanged, Settings.shared.activeAccount != nil else {
            shouldHandlePasteBoardChanged = true
            return
        }
        guard let content = UIPasteboard.general.string else { return }
        guard content.isLink else { return }
        let alert = UIAlertController(title: "打开链接", message: "是否打开链接： \(content)", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .default) { [unowned self] _ in
            self.linkActived(content)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(confirm)
        alert.addAction(cancel)
        topVC?.present(alert, animated: true, completion: nil)
    }
    
    func linkActived(_ url: String) {
        guard let url = URL(string: url) else { return }
        
        switch url.linkType {
        case .external:
            showExternalURL(url: url)
        case .downloadAttachment:
            topVC?.showPromptInformation(of: .failure("暂不支持下载论坛附件！"))
        case .viewThread:
            let readPostVC = PostViewController.load(from: .home)
            readPostVC.postInfo = PostInfo(urlString: url.absoluteString)
            if let navi = topVC?.navigationController {
                topVC?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navi.pushViewController(readPostVC, animated: true)
            } else {
                let navi = UINavigationController(rootViewController: readPostVC)
                navi.transitioningDelegate = topVC as? BaseViewController
                topVC?.present(navi, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    func showExternalURL(url: URL) {
        guard let scheme = url.scheme, scheme.contains("http") || scheme.contains("https") else {
            topVC?.showPromptInformation(of: .failure("无法识别链接：\(url)"))
            return
        }
        let safari = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            safari.preferredControlTintColor = C.Color.navigationBarTintColor
        }
        safari.delegate = self
        safari.transitioningDelegate = topVC as? BaseViewController
        topVC?.present(safari, animated: true, completion: nil)
    }
}

// MARK: - SFSafariViewControllerDelegate

extension URLDispatchManager: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        topVC?.dismiss(animated: true, completion: nil)
    }
}
