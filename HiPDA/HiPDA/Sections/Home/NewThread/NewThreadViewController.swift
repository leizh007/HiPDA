//
//  NewThreadViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import YYText
import YYImage
import RxSwift

private enum Constant {
    static let classification = "分类"
    static let contentLengthThreshold = 5
}

private enum TextViewType: Int {
    case title
    case content
}

private enum InputViewType {
    case text
    case emoticon
    
    var opposition: InputViewType {
        switch self {
        case .text:
            return .emoticon
        case .emoticon:
            return .text
        }
    }
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
    fileprivate var contentInputViewType = InputViewType.text
    fileprivate var contentInputView: UIView?
    fileprivate var viewModel = NewThreadViewModel()
    fileprivate var isSendButtonEnable: Bool {
        switch type {
        case .new(fid: _):
            return !titleTextView.text.isEmpty && contentTextView.text.characters.count > Constant.contentLengthThreshold
        default:
            return contentTextView.text.characters.count > Constant.contentLengthThreshold
        }
    }
    fileprivate var sendButtons = [UIBarButtonItem]()
    
    var typeName = Constant.classification {
        didSet {
            classificationButton.setTitle(typeName, for: .normal)
        }
    }
    
    fileprivate var typeid: Int {
        return ForumManager.typeid(of: typeName)
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
        configureAccessoryView()
        for constraint in seperatorLineHeightConstraints {
            constraint.constant = 1.0 / C.UI.screenScale
        }
        sendButtons.forEach { $0.isEnabled = self.isSendButtonEnable }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        titleTextView.becomeFirstResponder()
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        let closeButton =  UIBarButtonItem(image: #imageLiteral(resourceName: "navigationbar_close"), style: .plain, target: self, action: #selector(close))
        let postButton = UIBarButtonItem(image: #imageLiteral(resourceName: "new_thread_sent"), style: .plain, target: self, action: #selector(post))
        sendButtons.append(postButton)
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
            let parser = YYTextSimpleEmoticonParser()
            var mapper = [String: YYImage]()
            EmoticonHelper.groups.flatMap { $0.emoticons }.forEach { emocation in
                mapper[emocation.code] = YYImage(named: emocation.name)
            }
            parser.emoticonMapper = mapper
            textView.textParser = parser
        case .title:
            textView.placeholderText = "Title here..."
            textView.returnKeyType = .next
        }
    }
    
    fileprivate func skinContent(_ content: String) -> String {
        if Settings.shared.isEnabledTail {
            if let urlString = Settings.shared.tailURL?.absoluteString, !urlString.isEmpty {
                let text = Settings.shared.tailText.isEmpty ? urlString : Settings.shared.tailText
                return "\(content)    [url=\(urlString)][size=1]\(text)[/size][/url]"
            } else if !Settings.shared.tailText.isEmpty {
                return "\(content)    [size=1]\(Settings.shared.tailText)[/size]"
            } else {
                return content
            }
        } else {
            return content
        }
    }
    
    fileprivate func configureAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: 44.0))
        toolbar.tintColor = #colorLiteral(red: 0.3960784314, green: 0.4666666667, blue: 0.5254901961, alpha: 1)
        let photo = UIBarButtonItem(image: #imageLiteral(resourceName: "new_thread_toolbar_image"), style: .plain, target: self, action: #selector(photoButtonPressed))
        let emoji = UIBarButtonItem(image: #imageLiteral(resourceName: "new_thread_switch_emoji"), style: .plain, target: self, action: #selector(emojiButtonPressed(_:)))
        let sent = UIBarButtonItem(image: #imageLiteral(resourceName: "new_thread_sent"), style: .plain, target: self, action: #selector(post))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [photo, space, emoji, space, sent]
        sendButtons.append(sent)
        
        contentTextView.inputAccessoryView = toolbar
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
        showPromptInformation(of: .loading("正在发送..."))
        switch type {
        case let .new(fid):
            let typeid = self.typeid
            let title = titleTextView.text ?? ""
            let content = contentTextView.text ?? ""
            viewModel.postNewThread(fid: fid, typeid: typeid, title: title, content: skinContent(content)) { [unowned self] result in
                self.hidePromptInformation()
                switch result {
                case .success(let tid):
                    self.showPromptInformation(of: .success("发送成功!"))
                    delay(seconds: 0.25) {
                        self.presentingViewController?.dismiss(animated: true) {
                            URLDispatchManager.shared.linkActived("https://www.hi-pda.com/forum/viewthread.php?tid=\(tid)&extra=page%3D1")
                        }
                    }
                case .failure(let error):
                    self.showPromptInformation(of: .failure(error.description))
                }
            }
        default:
            break
        }
    }
    
    func photoButtonPressed() {
        
    }
    
    func emojiButtonPressed(_ sender: UIBarButtonItem) {
        contentInputViewType = contentInputViewType.opposition
        let image: UIImage
        let inputView: UIView?
        switch contentInputViewType {
        case .text:
            image = #imageLiteral(resourceName: "new_thread_switch_emoji")
            inputView = nil
        case .emoticon:
            image = #imageLiteral(resourceName: "new_thread_switch_keyboard")
            if let view = contentInputView {
                inputView = view
            } else {
                inputView = EmoticonInputView()
                (inputView as? EmoticonInputView)?.delegate = self
                contentInputView = inputView
            }
        }
        sender.image = image
        contentTextView.inputView = inputView
        contentTextView.reloadInputViews()
        contentTextView.becomeFirstResponder()
    }
}

// MARK: - EmoticonViewDelegate

extension NewThreadViewController: EmoticonViewDelegate {
    func emoticonInputDidTapText(_ text: String) {
        if !text.isEmpty, let range = contentTextView.selectedTextRange as? YYTextRange {
            contentTextView.replace(range, withText: text)
        }
    }
    
    func emoticonInputDidTapBackspace() {
        contentTextView.deleteBackward()
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
        sendButtons.forEach { $0.isEnabled = self.isSendButtonEnable }
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
