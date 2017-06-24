//
//  UserProfileSectionHeaderView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol UserProfileSectionHeaderDelegate: class {
    func sectionHeaderDidTapped(_ sectionHeader: UserProfileSectionHeaderView)
}

class UserProfileSectionHeaderView: UIView {
    @IBOutlet var seperatorHeightConstraints: [NSLayoutConstraint]!
    @IBOutlet fileprivate weak var headerTitleLabel: UILabel!
    weak var delegate: UserProfileSectionHeaderDelegate?
    @IBOutlet fileprivate weak var disclosureIndicatorView: UIImageView!
    @IBOutlet fileprivate weak var bottomSeperatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        seperatorHeightConstraints.forEach { $0.constant = CGFloat.from(pixel: 1) }
    }
    var headerTitle = "" {
        didSet {
            headerTitleLabel.text = headerTitle
        }
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        delegate?.sectionHeaderDidTapped(self)
        UIView.animate(withDuration: C.UI.animationDuration) {
            self.bottomSeperatorView.isHidden = !self.bottomSeperatorView.isHidden
            self.disclosureIndicatorView.transform = self.disclosureIndicatorView.transform.rotated(by: .pi)
        }
    }
}
