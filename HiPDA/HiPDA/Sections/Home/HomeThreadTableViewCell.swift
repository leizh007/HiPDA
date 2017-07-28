//
//  HomeThreadTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/7.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

private let kTitleMargin = CGFloat(8.0)

private enum Constant {
    static let margin = CGFloat(8)
    static let imageHeight = CGFloat(34.0)
}

class HomeThreadTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var timeDescriptionLabel: UILabel!
    @IBOutlet fileprivate weak var readCountLabel: UILabel!
    @IBOutlet fileprivate weak var countSeperatorLabel: UILabel!
    @IBOutlet fileprivate weak var replyCountLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var justForHeightCaculation = false
    var shouldChangeTitleTextColorWhenThreadIsRead = false
    
    var threadModel: HomeThreadModel? {
        didSet {
            guard let threadModel = threadModel, !justForHeightCaculation else { return }
            nameLabel.text = threadModel.userName
            timeDescriptionLabel.text = threadModel.timeString
            readCountLabel.text = "\(threadModel.readCount)"
            replyCountLabel.text = "\(threadModel.replyCount)"
            titleLabel.text = threadModel.title
            let placeholderImage = Settings.shared.useAvatarPlaceholder ? Avatar.placeholder : Avatar.blank
            avatarImageView.sd_setImage(with: threadModel.avatarImageURL, placeholderImage: placeholderImage, options: [.avoidAutoSetImage]) { [weak self] (image, _, _, _) in
                guard let `self` = self, let image = image else { return }
                DispatchQueue.global().async {
                    let corneredImage = image.image(roundCornerRadius: Avatar.cornerRadius, borderWidth: 1.0 / C.UI.screenScale, borderColor: .lightGray, size: CGSize(width: Avatar.width, height: Avatar.height))
                    DispatchQueue.main.async {
                        guard threadModel.avatarImageURL.absoluteString == self.threadModel?.avatarImageURL.absoluteString ?? "" else { return }
                        self.avatarImageView.image = corneredImage
                    }
                }
            }
            if shouldChangeTitleTextColorWhenThreadIsRead {
                titleLabel.textColor = threadModel.isRead ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                nameLabel.textColor = threadModel.isRead ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
                readCountLabel.textColor = threadModel.isRead ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
                countSeperatorLabel.textColor = threadModel.isRead ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
                replyCountLabel.textColor = threadModel.isRead ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
                timeDescriptionLabel.textColor = threadModel.isRead ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: C.UI.screenWidth, height: HomeThreadTableViewCell.titleHeight(for: threadModel?.title ?? "") + 3 * Constant.margin + Constant.imageHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.frame = CGRect(x: Constant.margin, y: Constant.margin, width: Constant.imageHeight, height: Constant.imageHeight)
        
        let avatarVerticalCenter = Constant.margin + avatarImageView.frame.size.height / 2
        nameLabel.sizeToFit()
        nameLabel.frame.origin = CGPoint(x: Constant.imageHeight + 2 * Constant.margin, y: avatarVerticalCenter - nameLabel.frame.size.height / 2)
        
        timeDescriptionLabel.sizeToFit()
        timeDescriptionLabel.frame.origin = CGPoint(x: C.UI.screenWidth - Constant.margin - timeDescriptionLabel.frame.size.width, y: avatarVerticalCenter - timeDescriptionLabel.frame.size.height / 2)
        
        readCountLabel.sizeToFit()
        readCountLabel.frame.origin = CGPoint(x: timeDescriptionLabel.frame.origin.x - Constant.margin - readCountLabel.frame.size.width, y: avatarVerticalCenter - readCountLabel.frame.size.height / 2)
        
        countSeperatorLabel.sizeToFit()
        countSeperatorLabel.frame.origin = CGPoint(x: readCountLabel.frame.origin.x - countSeperatorLabel.frame.size.width, y: avatarVerticalCenter - countSeperatorLabel.frame.size.height / 2)
        
        replyCountLabel.sizeToFit()
        replyCountLabel.frame.origin = CGPoint(x: countSeperatorLabel.frame.origin.x - replyCountLabel.frame.size.width, y: avatarVerticalCenter - replyCountLabel.frame.size.height / 2)
        
        titleLabel.frame = CGRect(x: Constant.margin, y: avatarImageView.frame.size.height + avatarImageView.frame.origin.y + Constant.margin, width: C.UI.screenWidth - 2 * Constant.margin, height: contentView.frame.size.height - avatarImageView.frame.origin.y - avatarImageView.frame.size.height - 2 * Constant.margin)
    }
    
    fileprivate static func titleHeight(for text: String) -> CGFloat {
        let titleMargin = CGFloat(8)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)
        ]
        let height = (text as NSString).boundingRect(with: CGSize(width: C.UI.screenWidth - 2 * titleMargin, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height
        return height.pixelCeil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        justForHeightCaculation = false
        avatarImageView.sd_cancelCurrentImageLoad()
    }
}
