//
//  NotificationViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 消息的ViewController
class MessageViewController: BaseViewController {
    @IBOutlet fileprivate var titleView: MessageNavigationBarTitleView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    fileprivate var messageViewControllers: [MessageTableViewController]!
    private let  contentWidth = C.UI.screenWidth
    private let contentHeight = C.UI.screenHeight - 64 - 49
    fileprivate var currentVisibleChildrenViewController: MessageTableViewController! {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        return messageViewControllers[index]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeEvenBus()
        skinScrollView()
        titleView.select(index: 0)
        titleView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(messageViewControllerTabRepeatedSelected), name: .MessageViewControllerTabRepeatedSelected, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func messageViewControllerTabRepeatedSelected() {
        currentVisibleChildrenViewController.messageViewControllerTabRepeatedSelected()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageViewControllers.forEach { $0 == self.currentVisibleChildrenViewController ? $0.viewDidBecomeVisible() : $0.viewDidBecomeInvisible() }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        messageViewControllers.forEach { $0.viewDidBecomeInvisible() }
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        
        titleView.frame = CGRect(x: 0, y: 0, width: 217, height: 44)
        navigationItem.titleView = titleView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        messageViewControllers.forEach { $0.view.frame.size = CGSize(width: contentWidth, height: contentHeight) }
    }
    
    fileprivate func skinScrollView() {
        messageViewControllers = []
        scrollView.contentSize = CGSize(width: contentWidth * 3, height: contentHeight)
        for (offset, ViewContrller) in [ThreadMessageViewController.self, PrivateMessageViewController.self, FriendMessageViewController.self].enumerated() {
            let vc = ViewContrller.init()
            vc.view.frame = CGRect(x: CGFloat(offset) * contentWidth, y: 0, width: contentWidth, height: contentHeight)
            scrollView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            messageViewControllers.append(vc)
        }
    }
}

// MARK: - MesssageNavigationBarTitleViewDelegate

extension MessageViewController: MesssageNavigationBarTitleViewDelegate {
    func itemDidSelect(_ index: Int) {
        let oldVC = currentVisibleChildrenViewController
        scrollView.contentOffset.x = CGFloat(index) * scrollView.frame.size.width
        let vc = currentVisibleChildrenViewController
        if oldVC != vc {
            messageViewControllers.forEach { $0 == vc ? $0.viewDidBecomeVisible() : $0.viewDidBecomeInvisible() }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension MessageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        titleView.configureApperance(with: scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            messageViewControllers.forEach { $0 == self.currentVisibleChildrenViewController ? $0.viewDidBecomeVisible() : $0.viewDidBecomeInvisible() }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        messageViewControllers.forEach { $0 == self.currentVisibleChildrenViewController ? $0.viewDidBecomeVisible() : $0.viewDidBecomeInvisible() }
    }
}

// MARK: - UnReadMessagesCount

extension MessageViewController {
    fileprivate func observeEvenBus() {
        EventBus.shared.unReadMessagesCount
            .do(onNext: { [weak self] model in
                self?.titleView.model = model
            })
            .map { $0.totalMessagesCount == 0 ? nil : "\($0.totalMessagesCount)" }
            .drive(navigationController!.tabBarItem.rx.badgeValue)
            .disposed(by: disposeBag)
        EventBus.shared.activeAccount.asObservable()
            .subscribe(onNext: { [weak self] loginResult in
                guard let loginResult = loginResult, case .success(let account) = loginResult else {
                    return
                }
                self?.messageViewControllers.forEach { $0.accountChanged(account) }
            })
            .disposed(by: disposeBag)
    }
}
