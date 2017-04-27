//
//  BaseViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    /// VC是否已经出现在屏幕上
    let viewDidAppear = Variable(false)
    
    // MARK: - Layout Constraints
    
    fileprivate(set) var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setNeedsUpdateConstraints()
        
        if let navigationBar = navigationController?.navigationBar {
            configureApperance(of: navigationBar)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear.value = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidAppear.value = false
    }
    
    override func updateViewConstraints() {
        if !self.didSetupConstraints {
            self.setupConstraints()
            self.didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupConstraints() {
        // Override point
    }
    
    /// 配置NavigationBar的外观
    ///
    /// - parameter navigationBar: 待配置的navigationBar
    func configureApperance(of navigationBar: UINavigationBar) {
    }
    
    // MARK: - UIViewController Transitioning Animator
    
    var useCustomViewControllerTransitioningAnimator = true
    
    lazy var transitioningAnimator = PresentAnimator()
}

// MARK: - UIViewControllerTransitioningDelegate

extension BaseViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioningAnimator.transitioningType = .present
        return useCustomViewControllerTransitioningAnimator ? transitioningAnimator : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioningAnimator.transitioningType = .dismiss
        return useCustomViewControllerTransitioningAnimator ? transitioningAnimator : nil
    }
}
