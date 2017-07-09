//
//  MyThreadsViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class MyThreadsViewController: BaseViewController {
    @IBOutlet fileprivate var titleView: MyThreadsNavigationBarTitleView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    private let contentWidth = C.UI.screenWidth
    private let contentHeight = C.UI.screenHeight - 64
    fileprivate var childThreadViewControllers = [MyThreadsBaseTableViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skinScrollView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        childThreadViewControllers[0].loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        childThreadViewControllers.forEach { $0.view.frame.size = CGSize(width: contentWidth, height: contentHeight) }
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        
        titleView.frame = CGRect(x: 0, y: 0, width: 152, height: 44)
        titleView.delegate = self
        navigationItem.titleView = titleView
        titleView.select(index: 0)
    }
    
    fileprivate func skinScrollView() {
        scrollView.contentSize = CGSize(width: 2 * contentWidth, height: contentHeight)
        for (offset, ViewController) in [MyTopicsViewController.self, MyPostsViewController.self].enumerated() {
            let vc = ViewController.init()
            vc.view.frame = CGRect(x: CGFloat(offset) * contentWidth, y: 0, width: contentWidth, height: contentHeight)
            scrollView.addSubview(vc.view)
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            childThreadViewControllers.append(vc)
        }
    }
}

// MARK: - MyThreadsNavigationBarTitleViewDelegate

extension MyThreadsViewController: MyThreadsNavigationBarTitleViewDelegate {
    func itemDidSelect(_ index: Int) {
        childThreadViewControllers[index].loadData()
        scrollView.contentOffset.x = CGFloat(index) * scrollView.frame.size.width
    }
    
    func itemDidSelectRepeatedly(_ index: Int) {
        childThreadViewControllers[index].tabBarItemDidSelectRepeatedly()
    }
}

// MARK: - UIScrollViewDelegate

extension MyThreadsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        titleView.configureApperance(with: scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
            childThreadViewControllers[index].loadData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        childThreadViewControllers[index].loadData()
    }
}

