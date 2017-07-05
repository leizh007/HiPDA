//
//  SearchTitleTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/5.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import SDWebImage

class SearchTitleTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var forumNameLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var readCountLabel: UILabel!
    @IBOutlet fileprivate weak var replyCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.preferredMaxLayoutWidth = C.UI.screenWidth - 16.0
    }
    
    var model: SearchTitleModelForUI! {
        didSet {
            let url = model.user.avatarImageURL.absoluteString
            avatarImageView.sd_setImage(with: model.user.avatarImageURL, placeholderImage: Avatar.placeholder, options: [.avoidAutoSetImage]) { [weak self] (image, _, _, _) in
                guard let `self` = self, let image = image else { return }
                DispatchQueue.global().async {
                    let corneredImage = image.image(roundCornerRadius: Avatar.cornerRadius, borderWidth: 1.0 / C.UI.screenScale, borderColor: .lightGray, size: CGSize(width: Avatar.width, height: Avatar.height))
                    DispatchQueue.main.async {
                        guard  url == self.model.user.avatarImageURL.absoluteString else { return }
                        self.avatarImageView.image = corneredImage
                    }
                }
            }
            usernameLabel.text = model.user.name
            forumNameLabel.text = model.forumName
            titleLabel.attributedText = model.title
            timeLabel.text = "发表时间: \(model.time)"
            readCountLabel.text = "查看: \(model.readCount)"
            replyCountLabel.text = "回复: \(model.replyCount)"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.sd_cancelCurrentImageLoad()
    }
}
