//
//  MyThreadsNavigationBarTitleView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

protocol MyThreadsNavigationBarTitleViewDelegate: class {
    func itemDidSelect(_ index: Int)
    func itemDidSelectRepeatedly(_ index: Int)
}

class MyThreadsNavigationBarTitleView: UIView {
    @IBOutlet private var labels: [UILabel]!
    weak var delegate: MyThreadsNavigationBarTitleViewDelegate?
    private var lastSelectedIndex = 0
    
    @IBAction private func labelsContainerViewDidTapped(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag ?? 0
        select(index: tag)
        if lastSelectedIndex != tag {
            delegate?.itemDidSelect(tag)
            lastSelectedIndex = tag
        } else {
            delegate?.itemDidSelectRepeatedly(tag)
        }
    }
    
    func configureApperance(with offset: CGFloat) {
        var lowerIndex = Int(floor(offset))
        if lowerIndex < 0 {
            lowerIndex = 0
        }
        var upperIndex = Int(ceil(offset))
        if upperIndex >= labels.count {
            upperIndex = labels.count - 1
        }
        let lowerFactor = 1 - (offset - CGFloat(lowerIndex))
        let upperFactor = 1 - (CGFloat(upperIndex) - offset)
        for (index, factor) in zip([lowerIndex, upperIndex], [lowerFactor, upperFactor]) {
            labels[index].textColor = UIColor(red: (101.0 - 72 * factor) / 255.0,
                                              green: (119.0 + 43 * factor) / 255.0,
                                              blue: (134.0 + 108 * factor) / 255.0,
                                              alpha: 1.0)
            labels[index].transform = CGAffineTransform(scaleX: 1.0 - 2.0 * (1 - factor) / 17.0,
                                                        y: 1.0 - 2.0 * (1 - factor) / 17.0)
        }
        lastSelectedIndex = Int(round(offset))
    }
    
    func select(index: Int) {
        guard index >= 0 && index < labels.count else { return }
        UIView.animate(withDuration: C.UI.animationDuration) {
            for i in 0..<self.labels.count {
                let label = self.labels[i]
                if i == index {
                    label.transform = .identity
                    label.textColor = #colorLiteral(red: 0.1137254902, green: 0.6352941176, blue: 0.9490196078, alpha: 1)
                } else {
                    label.transform = CGAffineTransform(scaleX: 15.0 / 17.0, y: 15.0 / 17.0)
                    label.textColor = #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
                }
            }
        }
    }
}
