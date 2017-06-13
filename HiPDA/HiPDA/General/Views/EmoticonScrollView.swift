//
//  EmoticonScrollView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/13.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import YYImage

protocol EmoticonScrollViewDelegate: class {
    func emoticonScrollViewDidTapCell(_ cell: EmoticonCollectionViewCell)
}

class EmoticonScrollView: UICollectionView {
    fileprivate var touchMoved = false
    fileprivate var magnifier: UIImageView!
    fileprivate var magnifierContent: YYAnimatedImageView!
    fileprivate weak var currentMagnifierCell: EmoticonCollectionViewCell?
    fileprivate var backspaceTimer: Timer?
    weak var emoticonScrollViewDelegate: EmoticonScrollViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .clear
        backgroundView = UIView()
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        clipsToBounds = false
        canCancelContentTouches = false
        isMultipleTouchEnabled = false
        
        magnifier = UIImageView(image: #imageLiteral(resourceName: "emoticon_keyboard_magnifier"))
        magnifierContent = YYAnimatedImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        magnifierContent.center.x = magnifier.frame.width / 2.0
        magnifier.addSubview(magnifierContent)
        magnifier.isHidden = true
        addSubview(magnifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        endBackspaceTimer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMoved = false
        guard let cell = cellForTouches(touches) else {
            return
        }
        currentMagnifierCell = cell
        showMagnifier(for: cell)
        if let _ = cell.imageView.image, !cell.isDelete {
            UIDevice.current.playInputClick()
        }
        if cell.isDelete {
            endBackspaceTimer()
            perform(#selector(startBackspaceTimer), with: nil, afterDelay: 0.5)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMoved = true
        if currentMagnifierCell != nil && currentMagnifierCell!.isDelete {
            return
        }
        guard let cell = cellForTouches(touches), !cell.isDelete else {
            hideMagnifier()
            return
        }
        currentMagnifierCell = cell
        showMagnifier(for: cell)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            hideMagnifier()
            endBackspaceTimer()
        }
        guard let cell = cellForTouches(touches) else { return }
        if let currentMagnifierCell = currentMagnifierCell {
            if (!currentMagnifierCell.isDelete && cell.emoticon != nil) || (!touchMoved && cell.isDelete) {
                emoticonScrollViewDelegate?.emoticonScrollViewDidTapCell(cell)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideMagnifier()
        endBackspaceTimer()
    }
    
    fileprivate func cellForTouches(_ touches: Set<UITouch>) -> EmoticonCollectionViewCell? {
        guard let touch = touches.first else { return nil }
        let point = touch.location(in: self)
        guard let indexPath = indexPathForItem(at: point) else { return nil }
        return cellForItem(at: indexPath) as? EmoticonCollectionViewCell
    }
    
    fileprivate func showMagnifier(for cell: EmoticonCollectionViewCell) {
        guard let _ = cell.imageView.image, !cell.isDelete else {
            hideMagnifier()
            return
        }
        
        let rect = cell.convert(cell.bounds, to: self)
        magnifier.center.x = rect.midX
        magnifier.frame.origin.y = rect.maxY - 9.0 - magnifier.frame.size.height
        magnifier.isHidden = false
        
        magnifierContent.image = cell.imageView.image
        magnifierContent.contentMode = max(magnifierContent.frame.size.width, magnifierContent.frame.size.height) > max(magnifierContent.image?.size.width ?? 0, magnifierContent.image?.size.height ?? 0) ? .center : .scaleAspectFit
        magnifierContent.frame.origin.y = 20.0
        
        magnifierContent.layer.removeAllAnimations()
        
        let animationDuration = 0.1
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseIn], animations: { 
            self.magnifierContent.frame.origin.y = 3.0
        }, completion: { _ in
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
                self.magnifierContent.frame.origin.y = 6.0
            }, completion: { _ in
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: { 
                    self.magnifierContent.frame.origin.y = 5.0
                }, completion: nil)
            })
        })
    }
    
    fileprivate func hideMagnifier() {
        magnifier.isHidden = true
    }
    
    func startBackspaceTimer() {
        endBackspaceTimer()
        let timer = Timer(timeInterval: 0.1, target: self, selector: #selector(backspace), userInfo: nil, repeats: true)
        backspaceTimer = timer
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    func backspace() {
        guard let cell = currentMagnifierCell, cell.isDelete, let delegate = self.emoticonScrollViewDelegate else { return }
        
        UIDevice.current.playInputClick()
        delegate.emoticonScrollViewDidTapCell(cell)
    }
    
    fileprivate func endBackspaceTimer() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startBackspaceTimer), object: nil)
        backspaceTimer?.invalidate()
        backspaceTimer = nil
    }
}
