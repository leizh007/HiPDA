//
//  ThreadMessageTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

private enum Constants {
    static let contentMargin = CGFloat(8.0)
    static let contentWidth = C.UI.screenWidth - 2 * CGFloat(8.0)
}

class ThreadMessageTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var yourPostLabel: UILabel!
    @IBOutlet fileprivate weak var senderPostLabel: UILabel!

    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var yourPost: String? {
        didSet {
            yourPostLabel.text = yourPost
        }
    }
    
    var senderPost: String? {
        didSet {
            senderPostLabel.text = senderPost
        }
    }
    
    var isRead = false
    
    func update() {
        let color = isRead ? #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1) : #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        titleLabel.textColor = color
        for label in [yourPostLabel!, senderPostLabel!] where label.text != nil {
            let text = label.text!
            let attri = NSMutableAttributedString(string: text)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byCharWrapping
            let attributes = [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16.0),
                NSForegroundColorAttributeName: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            ]
            attri.addAttributes(attributes, range: NSRange(location: 0, length: (text as NSString).length))
            let index = (text as NSString).range(of: ":").location
            if index != NSNotFound {
                attri.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: index + 1))
            }
            label.attributedText = attri
        }
    }
    
    fileprivate static func height(for text: String) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)
        ]
        let height = (text as NSString).boundingRect(with: CGSize(width: Constants.contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height
        return height.pixelCeil
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height = CGFloat(0.0)
        let titleHeight = ThreadMessageTableViewCell.height(for: title)
        height += Constants.contentMargin + titleHeight
        for post in [yourPost, senderPost] {
            if post != nil {
                height += ThreadMessageTableViewCell.height(for: post!) + Constants.contentMargin
            }
        }
        height += Constants.contentMargin
        
        return CGSize(width: Constants.contentWidth, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var offset = CGFloat(0.0)
        let titleHeight = ThreadMessageTableViewCell.height(for: title ?? "")
        titleLabel.frame = CGRect(x: Constants.contentMargin,
                                  y: Constants.contentMargin,
                                  width: Constants.contentWidth,
                                  height: titleHeight)
        offset = titleHeight + Constants.contentMargin
        for (post, label) in zip([yourPost, senderPost], [yourPostLabel, senderPostLabel]) {
            if post != nil {
                label!.isHidden = false
                let height = ThreadMessageTableViewCell.height(for: post!)
                label!.frame = CGRect(x: Constants.contentMargin,
                                      y: offset + Constants.contentMargin,
                                      width: Constants.contentWidth,
                                      height: height)
                offset += height + Constants.contentMargin
            } else {
                label!.isHidden = true
            }
        }
    }
}

extension ThreadMessageTableViewCell: NibLoadableView { }
