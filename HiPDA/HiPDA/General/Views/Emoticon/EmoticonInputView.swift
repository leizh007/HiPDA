//
//  EmoticonInputView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/12.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol EmoticonViewDelegate: class {
    func emoticonInputDidTapText(_ text: String)
    func emoticonInputDidTapBackspace()
}

private enum Constant {
    static let viewHeight = CGFloat(216.0)
    static let onePageCount = 20
    static let oneEmoticonHeight = CGFloat(50.0)
    static let toolbarHeight = CGFloat(37)
}

class EmoticonInputView: UIView {
    var toolbarButtons: [UIButton]!
    var collectionView: EmoticonScrollView!
    var pageControl: UIView!
    var emoticonGroups: [EmoticonGroup]!
    var emoticonGroupPageIndexes: [Int]!
    var emoticonGroupPageCounts: [Int]!
    var emoticonGroupTotalPageCount: Int!
    var currentPageIndex: Int!
    weak var delegate: EmoticonViewDelegate?
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: Constant.viewHeight))
        backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        _initGroups()
        _initTopLine()
        _initCollectionView()
        _initToolbar()
        
        currentPageIndex = NSNotFound
        if let button = toolbarButtons.first {
            toolbarButtonDidTapped(button)
        }
    }
}

// MARK: - Initializations

extension EmoticonInputView {
    fileprivate func _initGroups() {
        emoticonGroups = EmoticonHelper.groups
        var indexes = [Int]()
        indexes.reserveCapacity(emoticonGroups.count)
        var pageCounts = [Int]()
        pageCounts.reserveCapacity(emoticonGroups.count)
        var index = 0
        for group in emoticonGroups {
            indexes.append(index)
            var count = Int(ceil(Double(group.emoticons.count) / Double(Constant.onePageCount)))
            if count == 0 {
                count = 1
            }
            pageCounts.append(count)
            index += count
        }
        emoticonGroupPageIndexes = indexes
        emoticonGroupPageCounts = pageCounts
        emoticonGroupTotalPageCount = index
    }
    
    fileprivate func _initTopLine() {
        let line = UIView()
        line.frame = CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: CGFloat.from(pixel: 1))
        line.backgroundColor = #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
        addSubview(line)
    }
    
    fileprivate func _initCollectionView() {
        var itemWidth = (C.UI.screenWidth - 10 * 2) / 7.0
        itemWidth = itemWidth.pixelRound
        let padding = (C.UI.screenWidth - 7 * itemWidth) / 2.0
        let paddingLeft = padding.pixelRound
        let paddingRight = C.UI.screenWidth - paddingLeft - 7 * itemWidth
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemWidth, height: Constant.oneEmoticonHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: paddingLeft, bottom: 0, right: paddingRight)
        
        collectionView = EmoticonScrollView(frame: CGRect(x: 0, y: 5, width: C.UI.screenWidth, height: Constant.oneEmoticonHeight * 3), collectionViewLayout: layout)
        collectionView.register(EmoticonCollectionViewCell.self, forCellWithReuseIdentifier: EmoticonCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emoticonScrollViewDelegate = self
        addSubview(collectionView)
        
        pageControl = UIView()
        pageControl.frame.size = CGSize(width: C.UI.screenWidth, height: 20)
        pageControl.frame.origin.y = collectionView.frame.origin.y + collectionView.frame.size.height - 5
        pageControl.isUserInteractionEnabled = false
        addSubview(pageControl)
    }
    
    fileprivate func _initToolbar() {
        let toolbar = UIView()
        toolbar.frame.size = CGSize(width: C.UI.screenWidth, height: Constant.toolbarHeight)
        
        let bg = UIImageView(image: #imageLiteral(resourceName: "emotion_table_right_normal"))
        bg.frame = toolbar.bounds
        toolbar.addSubview(bg)
        
        let scrollView = UIScrollView(frame: toolbar.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentSize = toolbar.frame.size
        toolbar.addSubview(scrollView)
        
        toolbarButtons = [UIButton]()
        toolbarButtons.reserveCapacity(emoticonGroups.count)
        for i in 0..<emoticonGroups.count {
            let group = emoticonGroups[i]
            let button = _createToolbarButton()
            button.setTitle(group.name, for: .normal)
            button.frame.origin.x = CGFloat(i) * C.UI.screenWidth / CGFloat(emoticonGroups.count)
            button.tag = i
            scrollView.addSubview(button)
            toolbarButtons.append(button)
        }
        
        toolbar.frame.origin.y = frame.size.height - toolbar.frame.size.height
        addSubview(toolbar)
    }
}

// MARK: - Helper 

extension EmoticonInputView {
    fileprivate func _createToolbarButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.isExclusiveTouch = true
        button.frame.size = CGSize(width: C.UI.screenWidth / CGFloat(emoticonGroups.count), height: Constant.toolbarHeight)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.3647058824, green: 0.3607843137, blue: 0.3529411765, alpha: 1), for: .selected)
        
        var image = #imageLiteral(resourceName: "emotion_table_left_normal")
        image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width - 1), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        
        image = #imageLiteral(resourceName: "emotion_table_left_selected")
        image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width - 1), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .selected)
        
        button.addTarget(self, action: #selector(toolbarButtonDidTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    fileprivate func emoticon(for indexPath: IndexPath) -> Emoticon? {
        let section = indexPath.section
        for i in (0..<emoticonGroupPageIndexes.count).reversed() {
            let pageIndex = emoticonGroupPageIndexes[i]
            if section >= pageIndex {
                let page = section - pageIndex
                var index = page * Constant.onePageCount + indexPath.row
                let ip = index / Constant.onePageCount
                let ii = index % Constant.onePageCount
                let reIndex = (ii % 3) * 7 + ii / 3
                index = reIndex + ip * Constant.onePageCount
                
                return emoticonGroups[i].emoticons.safe[index]
            }
        }
        return nil
    }
}

// MARK: - Button Action

extension EmoticonInputView {
    func toolbarButtonDidTapped(_ sender: UIButton) {
        let groupIndex = sender.tag
        let page = emoticonGroupPageIndexes[groupIndex]
        let rect = CGRect(x: CGFloat(page) * collectionView.frame.size.width, y: 0, width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        collectionView.scrollRectToVisible(rect, animated: false)
        scrollViewDidScroll(collectionView)
    }
}

// MARK: - UICollectionViewDelegate

extension EmoticonInputView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if page < 0 {
            page = 0
        } else if page >= emoticonGroupTotalPageCount {
            page = emoticonGroupTotalPageCount - 1
        }
        currentPageIndex = page
        
        var curGroupIndex = 0, curGroupPageIndex = 0, curGroupPageCount = 0
        for i in (0..<emoticonGroupPageIndexes.count).reversed() {
            let pageIndex = emoticonGroupPageIndexes[i]
            if page >= pageIndex {
                curGroupIndex = i
                curGroupPageIndex = pageIndex
                curGroupPageCount = emoticonGroupPageCounts[i]
                break
            }
        }
        
        while (pageControl.layer.sublayers?.count ?? 0) > 0 {
            pageControl.layer.sublayers?.removeLast()
        }
        let padding = CGFloat(5), width = CGFloat(6), height = CGFloat(2)
        let pageControlWidth = (width + 2 * padding) * CGFloat(curGroupPageCount)
        for i in 0..<curGroupPageCount {
            let layer = CALayer()
            layer.frame.size = CGSize(width: width, height: height)
            layer.cornerRadius = 1
            if page - curGroupPageIndex == i {
                layer.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.5098039216, blue: 0.1450980392, alpha: 1).cgColor
            } else {
                layer.backgroundColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1).cgColor
            }
            layer.frame.origin.y = pageControl.frame.size.height / 2.0 - layer.frame.size.height / 2.0
            layer.frame.origin.x = (pageControl.frame.size.width - pageControlWidth) / 2.0 + CGFloat(i) * (width + 2 * padding) + padding
            pageControl.layer.addSublayer(layer)
        }
        for i in 0..<toolbarButtons.count {
            let button = toolbarButtons[i]
            button.isSelected = i == curGroupIndex
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - UICollectionViewDataSource

extension EmoticonInputView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emoticonGroupTotalPageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constant.onePageCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonCollectionViewCell.reuseIdentifier, for: indexPath) as? EmoticonCollectionViewCell else { fatalError() }
        if indexPath.row == Constant.onePageCount {
            cell.isDelete = true
            cell.emoticon = nil
        } else {
            cell.isDelete = false
            cell.emoticon = emoticon(for: indexPath)
        }
        
        return cell
    }
}

// MARK: - EmoticonScrollViewDelegate

extension EmoticonInputView: EmoticonScrollViewDelegate {
    func emoticonScrollViewDidTapCell(_ cell: EmoticonCollectionViewCell) {
        if cell.isDelete {
            UIDevice.current.playInputClick()
            delegate?.emoticonInputDidTapBackspace()
        } else if let emotion = cell.emoticon {
            delegate?.emoticonInputDidTapText(emotion.code)
        }
    }
}

// MARK: - UIInputViewAudioFeedback

extension EmoticonInputView: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool {
        return true
    }
}
