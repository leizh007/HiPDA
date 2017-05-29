//
//  ImageBrowserViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import SDWebImage

class ImageBrowserViewController: BaseViewController {
    var imageURLs: [String]!
    var selectedIndex: Int!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate

extension ImageBrowserViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ImageBrowserCollectionViewCell)?.resetState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ImageBrowserCollectionViewCell)?.resetState()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        console(message: String(describing: velocity))
        let spacing = CGFloat(20.0)
        var nthCell = Int(floor((scrollView.contentOffset.x + spacing) / (scrollView.frame.size.width + spacing)))
        if velocity.x > 0 {
            nthCell += 1
        } else if velocity.x < 0 {
            
        } else if scrollView.contentOffset.x < (scrollView.frame.size.width + spacing) * (CGFloat(nthCell) + 0.33)  {
            
        } else if scrollView.contentOffset.x > (scrollView.frame.size.width + spacing) * (CGFloat(nthCell) + 0.66) {
            nthCell += 1
        }
        if nthCell < 0 {
            nthCell = 0
        }
        if nthCell > imageURLs.count - 1 {
            nthCell = imageURLs.count - 1
        }
        let contentOffset = CGPoint(x: (scrollView.frame.size.width + spacing) * CGFloat(nthCell), y: 0.0)
        if fabs(velocity.x) > 1.5 {
            targetContentOffset.pointee = contentOffset
        } else {
            targetContentOffset.pointee = scrollView.contentOffset
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ImageBrowserViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageBrowserCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageBrowserCollectionViewCell else {
            fatalError()
        }
        cell.imageURLString = imageURLs[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImageBrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension ImageBrowserViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = imageURLs.filter { $0.contains(".thumb.jpg") }.map { $0.replacingOccurrences(of: ".thumb.jpg", with: "") }.flatMap { URL(string: $0) }
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
}

// MARK: - ImageBrowserCollectionViewCellDelegate

extension ImageBrowserViewController: ImageBrowserCollectionViewCellDelegate {
    func longPressedCell(_ cell: ImageBrowserCollectionViewCell) {
        console(message: "")
    }
}

// MARK: - StoryboardLoadable

extension ImageBrowserViewController: StoryboardLoadable {}
