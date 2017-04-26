//
//  HomeViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

/// 主页的ViewController
class HomeViewController: BaseViewController {
    /// 是否展示登录成功的提示信息
    fileprivate var showLoginSuccessInformation = true
    
    /// viewModel
    fileprivate var viewModel = HomeViewModel()
    
    /// 标题view
    @IBOutlet fileprivate var titleView: HomeNavigationBarTitleView!
    
    /// 论坛名称
    fileprivate var forumName: String {
        get {
            return viewModel.selectedForumName
        }
        
        set {
            refreshData.onNext(())
            viewModel.selectedForumName = newValue
            titleView.title = newValue
        }
    }
    
    /// 加载数据
    fileprivate let refreshData = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleLoginStatue()
        handlAutoRefreshData()
        titleView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        super.configureApperance(of: navigationBar)
        titleView.title = viewModel.selectedForumName
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "home_new_thread"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(newThreadButtonPressed(_:)))
    }
}

// MARK: - Button Action

extension HomeViewController {
    func newThreadButtonPressed(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: - AccountStatus 

extension HomeViewController {
    /// 处理登陆相关view展示
    fileprivate func handleLoginStatue() {
        if Settings.shared.lastLoggedInAccount != nil {
            self.showPromptInformation(of: .loading)
        } else {
            self.showLoginSuccessInformation = false
        }
        
        Driver.combineLatest(EventBus.shared.activeAccount, isAppeared.asDriver()) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .drive(onNext: { [weak self] (result) in
                guard let `self` = self, let result = result else { return }
                self.hidePromptInformation()
                switch result {
                case .success(_):
                    if self.showLoginSuccessInformation {
                        self.showPromptInformation(of: .success("登录成功"))
                        self.showLoginSuccessInformation = false
                    }
                case .failure(let error):
                    self.showPromptInformation(of: .failure("\(error)"))
                    self.showLoginSuccessInformation = false
                }
            }).addDisposableTo(disposeBag)
    }
}

// MARK: - Data Refresh

extension HomeViewController {
    /// 处理数据自动刷新相关
    fileprivate func handlAutoRefreshData() {
        Driver.combineLatest(refreshData.asDriver(onErrorJustReturn: ()), EventBus.shared.activeAccount, isAppeared.asDriver()) { ($0, $1, $2) }
            .debounce(0.1)
            .filter { $0.1 != nil && $0.2 }
            .map { $0.1! }
            .filter { result in
                switch result {
                case .success(_):
                    return true
                case .failure(_):
                    return false
                }
            }
            .drive(onNext: { [weak self] value in
                // 加载数据
                console(message: "加载数据: \(String(describing: self?.forumName))")
            })
            .disposed(by: disposeBag)
    }
    
    /// 更新view
    fileprivate func refreshView() {
        let name = forumName
        forumName = name
    }
}

// MARK: - HomeNavigationBarTitleViewDelegate

extension HomeViewController: HomeNavigationBarTitleViewDelegate {
    func titleViewClicked(titleView: HomeNavigationBarTitleView) {
        guard let forumNameSelectionViewController = storyboard?.instantiateViewController(withIdentifier: ForumNameSelectionViewController.identifier) as? ForumNameSelectionViewController else { return }
        forumNameSelectionViewController.modalPresentationStyle = .popover
        forumNameSelectionViewController.preferredContentSize = CGSize(width: 200, height: 250)
        forumNameSelectionViewController.popoverPresentationController?.sourceView = titleView
        forumNameSelectionViewController.popoverPresentationController?.sourceRect = titleView.bounds
        forumNameSelectionViewController.popoverPresentationController?.delegate = self
        forumNameSelectionViewController.forumNames = viewModel.forumNames
        forumNameSelectionViewController.selectedForumName = viewModel.selectedForumName
        forumNameSelectionViewController.delegate = self
        present(forumNameSelectionViewController, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        titleView.resetDisclosureImageViewStatus()
        
        return true
    }
}

// MARK: - ForumNameSelectionDelegate

extension HomeViewController: ForumNameSelectionDelegate {
    func forumNameDidSelected(forumName: String) {
        if self.forumName == forumName {
            titleView.resetDisclosureImageViewStatus()
        } else {
            self.forumName = forumName
        }
    }
}
