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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerUnReadMessagesCount()
        skinScrollView()
        titleView.select(index: 0)
        titleView.delegate = self
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        
        titleView.frame = CGRect(x: 0, y: 0, width: 217, height: 44)
        navigationItem.titleView = titleView
    }
    
    fileprivate func skinScrollView() {
        let bottomSpacing = CGFloat(49)
        let topSpacging = CGFloat(64)
        scrollView.contentSize = CGSize(width: C.UI.screenWidth * 3, height: C.UI.screenHeight - topSpacging - bottomSpacing)
        let view1 = UIView(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: C.UI.screenHeight - topSpacging - bottomSpacing))
        let view2 = UIView(frame: CGRect(x: C.UI.screenWidth, y: 0, width: C.UI.screenWidth, height: C.UI.screenHeight - topSpacging - bottomSpacing))
        let view3 = UIView(frame: CGRect(x: 2 * C.UI.screenWidth, y: 0, width: C.UI.screenWidth, height: C.UI.screenHeight - topSpacging - bottomSpacing))
        view1.backgroundColor = .yellow
        view2.backgroundColor = .green
        view3.backgroundColor = .red
        scrollView.addSubview(view1)
        scrollView.addSubview(view2)
        scrollView.addSubview(view3)
    }
}

// MARK: - MesssageNavigationBarTitleViewDelegate

extension MessageViewController: MesssageNavigationBarTitleViewDelegate {
    func itemDidSelect(_ index: Int) {
        scrollView.contentOffset.x = CGFloat(index) * scrollView.frame.size.width
    }
}

// MARK: - UIScrollViewDelegate

extension MessageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        titleView.configureApperance(with: scrollView.contentOffset.x / scrollView.frame.size.width)
    }
}

// MARK: - UnReadMessagesCount

extension MessageViewController {
    fileprivate func observerUnReadMessagesCount() {
        EventBus.shared.unReadMessagesCount
            .do(onNext: { [weak self] model in
                self?.titleView.model = model
            })
            .map { $0.totalMessagesCount == 0 ? nil : "\($0.totalMessagesCount)" }
            .drive(navigationController!.tabBarItem.rx.badgeValue)
            .disposed(by: disposeBag)
    }
}
