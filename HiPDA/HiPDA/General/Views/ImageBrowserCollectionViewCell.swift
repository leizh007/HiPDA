//
//  ImageBrowserCollectionViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

protocol ImageBrowserCollectionViewCellDelegate: class {
    func pressed(cell: ImageBrowserCollectionViewCell)
    func longPressedCell(_ cell: ImageBrowserCollectionViewCell)
}

private func screenAspectFitSizeOf(image: UIImage?) -> CGSize {
    guard let image = image, image.size.width > 0 && image.size.height > 0 else { return UIScreen.main.bounds.size }
    guard !image.isLongImage else { return CGSize(width: C.UI.screenWidth, height: image.size.height * C.UI.screenWidth / image.size.width) }
    let widthScale = image.size.width / C.UI.screenWidth
    let heightScale = image.size.height / C.UI.screenHeight
    let scale = max(widthScale, heightScale)
    return CGSize(width: image.size.width / scale, height: image.size.height / scale)
}

private func maximumZoomScaleFor(image: UIImage?) -> CGFloat {
    guard let image = image else { return 1.0 }
    guard !image.isLongImage else { return 1.0 }
    let widthScale = image.size.width / C.UI.screenWidth
    let heightScale = image.size.height / C.UI.screenHeight
    let scale = max(widthScale, heightScale)
    return max(scale, 2.0)
}

class ImageBrowserCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var imageView: FLAnimatedImageView!
    @IBOutlet fileprivate weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: ImageBrowserCollectionViewCellDelegate?
    
    // https://github.com/evgenyneu/ios-imagescroll-swift
    private func updateImageViewSize(_ size: CGSize) {
        imageViewWidthConstraint.constant = size.width
        imageViewHeightConstraint.constant = size.height
        updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let imageWidth = imageViewWidthConstraint.constant
        let imageHeight = imageViewHeightConstraint.constant
        
        scrollViewWidthConstraint.constant = min(scrollView.zoomScale * imageWidth, bounds.size.width)
        scrollViewHeightConstraint.constant = min(scrollView.zoomScale * imageHeight, bounds.size.height)
        
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.whiteLarge)
        scrollView.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        addGestureRecognizer(longPressRecognizer)
        
        updateImageViewSize(UIScreen.main.bounds.size)
    }
    
    var imageURLString: String = "" {
        didSet {
            resetState()
            if imageURLString.hasSuffix(".thumb.jpg") {
                updateImage(with: imageURLString.replacingOccurrences(of: ".thumb.jpg", with: ""))
            } else {
                updateImage(with: imageURLString)
            }
        }
    }
    
    fileprivate func updateImage(with urlString: String) {
        isImageLoaded = false
        imageView.sd_setImage(with: URL(string: urlString)) { [weak self] (image, error, _, _) in
            self?.updateImageViewSize(screenAspectFitSizeOf(image: image))
            self?.scrollView.maximumZoomScale = maximumZoomScaleFor(image: image)
            self?.isImageLoaded = true
        }
    }
    
    override func prepareForReuse() {
        scrollView.maximumZoomScale = 1.0
        resetState()
        imageView.sd_cancelCurrentImageLoad()
        updateImageViewSize(UIScreen.main.bounds.size)
    }
    
    func resetState() {
        scrollView.zoomScale = 1.0
    }
    
    var isImageLoaded = false
    
    func singleTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.pressed(cell: self)
    }
    
    // https://stackoverflow.com/questions/3967971/how-to-zoom-in-out-photo-on-double-tap-in-the-iphone-wwdc-2010-104-photoscroll
    func doubleTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard isImageLoaded else { return }
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let rect = zoomRect(for: scrollView.maximumZoomScale, with: tapGestureRecognizer.location(in: scrollView))
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    func longPressed(_ sender: UILongPressGestureRecognizer) {
        guard isImageLoaded else { return }
        if sender.state == .began {
            delegate?.longPressedCell(self)
        }
    }
    
    fileprivate func zoomRect(for scale: CGFloat, with center: CGPoint) -> CGRect {
        var zoomRect = CGRect()
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        let center = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        return zoomRect
    }
}

// MARK: - UIScrollViewDelegate

extension ImageBrowserCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
