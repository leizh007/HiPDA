//
//  ImageBrowserCollectionViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/29.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

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
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var imageViewBottomConstraint: NSLayoutConstraint!
    
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
        
        let viewWidth = bounds.size.width
        let viewHeight = bounds.size.height
        
        // center image if it is smaller than screen
        var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
        if hPadding < 0 { hPadding = 0 }
        
        var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
        if vPadding < 0 { vPadding = 0 }
        
        imageViewLeadingConstraint.constant = hPadding
        imageViewTrailingConstraint.constant = hPadding
        
        imageViewTopConstraint.constant = vPadding
        imageViewBottomConstraint.constant = vPadding
        
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.gray)
        scrollView.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    var imageURLString: String = "" {
        didSet {
            resetState()
            if imageURLString.hasSuffix(".thumb.jpg") {
                imageView.sd_setImage(with: URL(string: imageURLString)) { [weak self] (image, error, _, _) in
                    guard let `self` = self else { return }
                    self.updateImageViewSize(screenAspectFitSizeOf(image: image))
                    self.scrollView.maximumZoomScale = maximumZoomScaleFor(image: image)
                    self.updateImage(with: self.imageURLString.replacingOccurrences(of: ".thumb.jpg", with: ""))
                }
            } else {
                updateImage(with: imageURLString)
            }
        }
    }
    
    fileprivate func updateImage(with urlString: String) {
        imageView.sd_setImage(with: URL(string: imageURLString)) { [weak self] (image, error, _, _) in
            self?.updateImageViewSize(screenAspectFitSizeOf(image: image))
            self?.scrollView.maximumZoomScale = maximumZoomScaleFor(image: image)
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
    
    // https://stackoverflow.com/questions/3967971/how-to-zoom-in-out-photo-on-double-tap-in-the-iphone-wwdc-2010-104-photoscroll
    func doubleTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let rect = zoomRect(for: scrollView.maximumZoomScale, with: tapGestureRecognizer.location(in: scrollView))
            scrollView.zoom(to: rect, animated: true)
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imageView.frame.size.height < self.bounds.size.height {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0.0), animated: false)
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
