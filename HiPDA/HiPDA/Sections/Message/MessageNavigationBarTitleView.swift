//
//  MessageNavigationBarTitleView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol MesssageNavigationBarTitleViewDelegate: class {
    func itemDidSelect(_ index: Int)
}

class MessageNavigationBarTitleView: UIView {
    @IBOutlet private var messagesCountLabels: [UILabel]!
    @IBOutlet private var messageLabels: [UILabel]!
    weak var delegate: MesssageNavigationBarTitleViewDelegate?
    
    var model: UnReadMessagesCountModel! {
        didSet {
            messagesCountLabels[0].text = "\(model.threadMessagesCount)"
            messagesCountLabels[1].text = "\(model.pmMessagesCount)"
            messagesCountLabels[2].text = "\(model.friendMessagesCount)"
            messagesCountLabels[0].isHidden = model.threadMessagesCount == 0
            messagesCountLabels[1].isHidden = model.pmMessagesCount == 0
            messagesCountLabels[2].isHidden = model.friendMessagesCount == 0
        }
    }
    
    @IBAction private func messagesContainerViewDidTapped(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag ?? 0
        select(index: tag)
        delegate?.itemDidSelect(tag)
    }
    
    func configureApperance(with offset: CGFloat) {
        var lowerIndex = Int(floor(offset))
        if lowerIndex < 0 {
            lowerIndex = 0
        }
        var upperIndex = Int(ceil(offset))
        if upperIndex >= messagesCountLabels.count {
            upperIndex = messagesCountLabels.count - 1
        }
        let lowerFactor = 1 - (offset - CGFloat(lowerIndex))
        let upperFactor = 1 - (CGFloat(upperIndex) - offset)
        for (index, factor) in zip([lowerIndex, upperIndex], [lowerFactor, upperFactor]) {
            messageLabels[index].textColor = UIColor(red: (101.0 - 72 * factor) / 255.0,
                                                          green: (119.0 + 43 * factor) / 255.0,
                                                          blue: (134.0 + 108 * factor) / 255.0,
                                                          alpha: 1.0)
            messageLabels[index].transform = CGAffineTransform(scaleX: 1.0 - 2.0 * (1 - factor) / 17.0,
                                                                    y: 1.0 - 2.0 * (1 - factor) / 17.0)
        }
    }
    
    func select(index: Int) {
        guard index >= 0 && index < messageLabels.count else { return }
        UIView.animate(withDuration: C.UI.animationDuration) {
            for i in 0..<self.messageLabels.count {
                let label = self.messageLabels[i]
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
