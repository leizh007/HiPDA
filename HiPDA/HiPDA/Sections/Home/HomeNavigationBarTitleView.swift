//
//  HomeNavigationBarTitleView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/4/26.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol HomeNavigationBarTitleViewDelegate: class {
    func titleViewClicked(titleView: HomeNavigationBarTitleView)
}

private let contentMargin = CGFloat(8.0)

/// 主页navigationBar的标题视图
class HomeNavigationBarTitleView: UIView {
    /// 标题label
    @IBOutlet private weak var titleLabel: UILabel!
    
    /// 展开提示imageView
    @IBOutlet private weak var disclosureImageView: UIImageView!
    
    /// 恢复提示图的状态
    func resetDisclosureImageViewStatus() {
        UIView.animate(withDuration: C.UI.animationDuration) {
            self.disclosureImageView.transform = .identity
        }
    }
    
    /// 标题
    var title: String? {
        get {
            return titleLabel.text
        }
        
        set {
            titleLabel.text = newValue
            UIView.animate(withDuration: C.UI.animationDuration) {
                self.disclosureImageView.transform = .identity
            }
        }
    }
    
    @IBAction private func titleViewClicked(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: C.UI.animationDuration) { 
            self.disclosureImageView.transform = self.disclosureImageView.transform.rotated(by: .pi)
        }
        delegate?.titleViewClicked(titleView: self)
    }
    
    /// 点击的代理对象
    weak var delegate: HomeNavigationBarTitleViewDelegate?
}
