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

class HomeThreadTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var timeDescriptionLabel: UILabel!
    @IBOutlet fileprivate weak var readCountLabel: UILabel!
    @IBOutlet fileprivate weak var replyCountLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.preferredMaxLayoutWidth = kScreenWidth - 2 * kTitleMargin
    }
    
    var threadModel: HomeThreadModel? {
        didSet {
            guard let threadModel = threadModel else { return }
            nameLabel.text = threadModel.userName
            timeDescriptionLabel.text = threadModel.timeString
            readCountLabel.text = "\(threadModel.readCount)"
            replyCountLabel.text = "\(threadModel.replyCount)"
            titleLabel.text = threadModel.title
            avatarImageView.sd_setImage(with: threadModel.avatarImageURL, placeholderImage: nil, options: [.avoidAutoSetImage]) { [weak self] (image, _, _, _) in
                guard let `self` = self else { return }
                let image = image ?? #imageLiteral(resourceName: "avatar_placeholder")
                DispatchQueue.global().async {
                    let corneredImage = image.image(roundCornerRadius: 15.0, borderWidth: 1.0, borderColor: .lightGray)
                    DispatchQueue.main.async {
                        guard threadModel.avatarImageURL.absoluteString == self.threadModel?.avatarImageURL.absoluteString ?? "" else { return }
                        self.avatarImageView.image = corneredImage
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.sd_cancelCurrentImageLoad()
    }
}
