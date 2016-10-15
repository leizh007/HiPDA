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
    
    // MARK: - Layout Constraints
    
    fileprivate(set) var didSetupConstraints = false
    
    override func viewDidLoad() {
        self.view.setNeedsUpdateConstraints()
        transitioningDelegate = presentingViewController as? UIViewControllerTransitioningDelegate ?? self
    }
    
    override func updateViewConstraints() {
        if !self.didSetupConstraints {
            self.setupConstraints()
            self.didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    func setupConstraints() {
        // Override point
    }
    
    // MARK: - UIViewController Transitioning Animator
    
    var useCustomViewControllerTransitioningAnimator = true
    
    var transitioningAnimator = PresentAnimator()
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
