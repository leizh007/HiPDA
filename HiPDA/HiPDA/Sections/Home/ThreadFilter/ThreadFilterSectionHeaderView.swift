//
//  ThreadFilterSectionHeaderView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

protocol ThreadFilterSectionHeaderDelegate: class {
    func sectionHeaderDidTapped(_ sectionHeader: ThreadFilterSectionHeaderView)
}

class ThreadFilterSectionHeaderView: UIView {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var subTitleLabel: UILabel!
    @IBOutlet fileprivate weak var disclosureImageView: UIImageView!
    @IBOutlet fileprivate weak var seperatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var seperatorView: UIView!
    weak var delegate: ThreadFilterSectionHeaderDelegate?
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    var subTitle: String! {
        didSet {
            subTitleLabel.text = subTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        seperatorHeightConstraint.constant = 1.0 / C.UI.screenScale
    }
    
    @IBAction fileprivate func backgroundTapped(_ sender: UITapGestureRecognizer) {
        delegate?.sectionHeaderDidTapped(self)
        UIView.animate(withDuration: C.UI.animationDuration) {
            self.seperatorView.isHidden = !self.seperatorView.isHidden
            self.disclosureImageView.transform = self.disclosureImageView.transform.rotated(by: .pi)
        }
    }
}
