//
//  NewThreadViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import YYText

private enum Constant {
    static let classification = "分类"
}

enum TextViewType: Int {
    case title
    case content
}

class NewThreadViewController: BaseViewController {
    var type = NewThreadType.new(fid: 0)
    var typeNames = [String]()
    @IBOutlet fileprivate weak var titleTextView: YYTextView!
    @IBOutlet fileprivate weak var contentTextView: YYTextView!
    fileprivate var activeTextView: YYTextView?
    @IBOutlet fileprivate var seperatorLineHeightConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var classificationButton: UIButton!
    var typeName = Constant.classification {
        didSet {
            classificationButton.setTitle(typeName, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = type.description
        if case .new(fid: let fid) = type {
            typeNames = ForumManager.typeNames(of: fid)
        }
        classificationButton.isHidden = typeNames.count == 0
        typeNames.insert(Constant.classification, at: 0)
        
        skinTextView(titleTextView)
        skinTextView(contentTextView)
        for constraint in seperatorLineHeightConstraints {
            constraint.constant = 1.0 / C.UI.screenScale
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        titleTextView.becomeFirstResponder()
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        let closeButton =  UIBarButtonItem(image: #imageLiteral(resourceName: "navigationbar_close"), style: .plain, target: self, action: #selector(close))
        let postButton = UIBarButtonItem(image: #imageLiteral(resourceName: "new_thread_sent"), style: .plain, target: self, action: #selector(post))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = postButton
    }
    
    fileprivate func skinTextView(_ textView: YYTextView) {
        textView.textContainerInset = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
        textView.showsVerticalScrollIndicator = false
        textView.alwaysBounceVertical = true
        textView.font = UIFont.systemFont(ofSize: 17.0)
        textView.placeholderFont = UIFont.systemFont(ofSize: 17.0)
        textView.placeholderTextColor = #colorLiteral(red: 0.7058823529, green: 0.7058823529, blue: 0.7058823529, alpha: 1)
        textView.delegate = self
        guard let type = TextViewType(rawValue: textView.tag) else { return }
        switch type {
        case .content:
            textView.placeholderText = "Content here..."
        case .title:
            textView.placeholderText = "Title here..."
            textView.returnKeyType = .next
        }
    }
    
    @IBAction fileprivate func classificationButtonPressed(_ sender: UIButton) {
        activeTextView?.resignFirstResponder()
        let pickerActionSheetController = PickerActionSheetController.load(from: .views)
        pickerActionSheetController.pickerTitles = typeNames
        pickerActionSheetController.initialSelelctionIndex = typeNames.index(of: typeName) ?? 0
        pickerActionSheetController.selectedCompletionHandler = { [unowned self] index in
            self.dismiss(animated: false, completion: nil)
            if let index = index, let typeName = self.typeNames.safe[index] {
                self.typeName = typeName
            }
            self.activeTextView?.becomeFirstResponder()
        }
        pickerActionSheetController.modalPresentationStyle = .overCurrentContext
        present(pickerActionSheetController, animated: false, completion: nil)
    }
}

// MARK: - Button Action

extension NewThreadViewController {
    func close() {
        view.endEditing(true)
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func post() {
        view.endEditing(true)
    }
}

// MARK: - StoryboardLoadable

extension NewThreadViewController: StoryboardLoadable {}

// MARK: - YYTextViewDelegate

extension NewThreadViewController: YYTextViewDelegate {
    func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView == titleTextView else { return true }
        if text == "\n" && textView == titleTextView {
            titleTextView.resignFirstResponder()
            contentTextView.becomeFirstResponder()
        }
        return !text.contains("\n")
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        if textView == titleTextView {
            textView.isScrollEnabled = textView.contentSize.height > textView.frame.size.height
        }
    }
    
    func textViewDidEndEditing(_ textView: YYTextView) {
        if textView == titleTextView {
            textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
    }
    
    func textViewDidBeginEditing(_ textView: YYTextView) {
        activeTextView = textView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == activeTextView {
            view.endEditing(true)
        }
    }
}
