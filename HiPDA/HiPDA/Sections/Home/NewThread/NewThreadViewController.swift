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
import Photos

private enum Constant {
    static let classification = "分类"
    static let contentLengthThreshold = 5
    static let ifUserAgreedEULA = "ifUserAgreedEULA"
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
    var draft: Draft?
    var draftSendSuccessCompletion: ((Void) -> Void)?
    var draftEditCompleted: ((Draft) -> Void)?
    var type = NewThreadType.new(fid: 0)
    var typeNames = [String]()
    var sendPostCompletion: ((String) -> Void)?
    @IBOutlet fileprivate weak var titleTextView: YYTextView!
    @IBOutlet fileprivate weak var contentTextView: YYTextView!
    fileprivate var activeTextView: YYTextView?
    @IBOutlet fileprivate var seperatorLineHeightConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var classificationButton: UIButton!
    fileprivate var contentInputViewType = InputViewType.text
    fileprivate var contentInputView: UIView?
    fileprivate var viewModel: NewThreadViewModel!
    fileprivate var sendButtons = [UIBarButtonItem]()
    
    fileprivate let typeNameVariable = Variable(Constant.classification)
    fileprivate let titleVariable = Variable("")
    fileprivate let contentVariable = Variable("")
    fileprivate let sendButtonPressedPublishSubject = PublishSubject<Void>()
    fileprivate let closePublishSubject = PublishSubject<Void>()
    
    var typeName = Constant.classification {
        didSet {
            classificationButton.setTitle(typeName, for: .normal)
            typeNameVariable.value = typeName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let draft = draft {
            type = .new(fid: draft.fid)
            typeName = draft.typeName
        }
        title = type.description
        if case .new(fid: let fid) = type {
            typeNames = ForumManager.typeNames(of: fid)
        }
        classificationButton.isHidden = typeNames.count == 0
        typeNames.insert(Constant.classification, at: 0)
        if case .new(_) = type {
            titleContainerView.isHidden = false
        } else {
            titleContainerView.isHidden = true
        }
        
        skinTextView(titleTextView)
        skinTextView(contentTextView)
        configureAccessoryView()
        for constraint in seperatorLineHeightConstraints {
            constraint.constant = 1.0 / C.UI.screenScale
        }
        skinViewModel()
        if let draft = draft {
            titleTextView.text = draft.title
            contentTextView.text = draft.content
            viewModel.imageNumbers = draft.imageNumbers
        }
        showEULAIfUserHasNotAgreed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if titleContainerView.isHidden {
            contentTextView.becomeFirstResponder()
        } else if let textView = activeTextView {
            textView.becomeFirstResponder()
        } else {
            titleTextView.becomeFirstResponder()
        }
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        let closeButton =  UIBarButtonItem(image: #imageLiteral(resourceName: "navigationbar_close"), style: .plain, target: nil, action: nil)
        closeButton.rx.tap.bindTo(closePublishSubject).disposed(by: disposeBag)
        let postButton = UIBarButtonItem(image: #imageLiteral(resourceName: "new_thread_sent"), style: .plain, target: self, action: #selector(post))
        sendButtons.append(postButton)
        postButton.isEnabled = false
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = postButton
    }
    
    fileprivate func showEULAIfUserHasNotAgreed() {
        let agreed = UserDefaults.standard.bool(forKey: Constant.ifUserAgreedEULA)
        if agreed {
            return
        }
        let message = "欢迎使用HiPDA，本软件许可使用协议由您和开发者Zhen Lei共同签署。\n" +
        "请您在发布内容之前，仔细阅读以下协议。如果您同意接受本协议所有条款和条件约束，可以继续发布内容；如您不同意本协议条款和条件，则无法发布内容。\n" +
        "发布内容需满足以下要求：\n" +
        "1，发言请文明，不得骂人，脏话，不管是回帖还是PM，都不允许，被骂了可以告状，但不要回骂，回骂会被扣分或者ban（视情节严重）;\n" +
        "2，不要挑起事端，引起纠纷，钓鱼者会被办，发言请对事不对人，不要人身攻击;\n" +
        "3，色情相关的帖子或图片请不要发，轻则扣分删贴，重则办ID。"
        let alert = UIAlertController(title: "用户许可协议", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "不同意", style: .cancel) { [unowned self] _ in
            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        let agree = UIAlertAction(title: "同意", style: .default) { _ in
            UserDefaults.standard.set(true, forKey: Constant.ifUserAgreedEULA)
        }
        alert.addAction(cancel)
        alert.addAction(agree)
        present(alert, animated: true, completion: nil)
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
            let parser = EmoticonParser()
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
    
    fileprivate func skinViewModel() {
        viewModel = NewThreadViewModel(type: type, typeName: typeNameVariable.asDriver(), title: titleVariable.asDriver(), content: contentVariable.asDriver(), sendButtonPresed: sendButtonPressedPublishSubject, closeButtonPressed: closePublishSubject)
        viewModel.isSendButtonEnabled.asObservable().subscribe(onNext: { [weak self] isEnabled in
            self?.sendButtons.forEach { $0.isEnabled = isEnabled }
        }).disposed(by: disposeBag)
        sendButtonPressedPublishSubject.subscribe(onNext: { [weak self] _ in
            self?.showPromptInformation(of: .loading("正在发送..."))
        }).disposed(by: disposeBag)
        viewModel.failure.subscribe(onNext: { [weak self] errorMesssage in
            self?.hidePromptInformation()
            self?.showPromptInformation(of: .failure(errorMesssage))
        }).disposed(by: disposeBag)
        viewModel.successNewThread.subscribe(onNext: { [unowned self] tid in
            self.hidePromptInformation()
            self.showPromptInformation(of: .success("发送成功!"))
            self.draftSendSuccessCompletion?()
            delay(seconds: 0.25) {
                self.presentingViewController?.dismiss(animated: true) {
                    if case .new(_) = self.type {
                        URLDispatchManager.shared.linkActived("https://www.hi-pda.com/forum/viewthread.php?tid=\(tid)&extra=page%3D1")
                    }
                }
            }
        }).disposed(by: disposeBag)
        viewModel.successOther.subscribe(onNext: { [unowned self] html in
            self.hidePromptInformation()
            self.showPromptInformation(of: .success("发送成功!"))
            self.draftSendSuccessCompletion?()
            self.sendPostCompletion?(html)
            delay(seconds: 0.25) {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
        viewModel.draftAfterCloseButtonPressed.subscribe(onNext: { [unowned self] draft in
            self.view.endEditing(true)
            guard let draft = draft else {
                self.close()
                return
            }
            let alert = UIAlertController(title: "关闭", message: "是否保存为草稿?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel) { _ in
                self.close()
            }
            let save = UIAlertAction(title: "保存", style: .default) { _ in
                if let completion = self.draftEditCompleted {
                    completion(draft)
                } else {
                    DraftManager.shared.addDraft(draft)
                }
                self.close()
            }
            alert.addAction(cancel)
            alert.addAction(save)
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
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
        sent.isEnabled = false
        
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
        sendButtonPressedPublishSubject.onNext(())
    }
    
    func photoButtonPressed() {
        view.endEditing(true)
        PHPhotoLibrary.checkPhotoLibraryPermission { granted in
            if granted {
                let vc = ImagePickerViewController.load(from: .views)
                vc.pageURLPath = self.type.pageURLPath
                vc.delegate = self
                let navi = UINavigationController(rootViewController: vc)
                navi.transitioningDelegate = self
                self.present(navi, animated: true, completion: nil)
            } else {
                self.showPromptInformation(of: .failure("已拒绝相册的访问申请，请到设置中开启相册的访问权限！"))
            }
        }
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

// MARK: - ImagePickerDelegate

extension NewThreadViewController: ImagePickerDelegate {
    func imagePicker(_ imagePicker: ImagePickerViewController, didFinishUpload imageNumbers: [Int]) {
        viewModel.imageNumbers.append(contentsOf: imageNumbers)
        let selectedRange = contentTextView.selectedRange
        let text = NSMutableAttributedString()
        text.append(contentTextView.attributedText ?? NSAttributedString())
        if imageNumbers.count > 0 {
            text.yy_appendString("\n")
        }
        imageNumbers.forEach { num in
            text.yy_appendString("\n")
            
            let str = NSMutableAttributedString(string: "[attachimg]\(num)[/attachimg]")
            str.yy_setTextBinding(YYTextBinding(deleteConfirm: false), range: str.yy_rangeOfAll())
            
            text.append(str)
            text.yy_appendString("\n")
        }
        if imageNumbers.count > 0 {
            text.yy_appendString("\n")
        }
        contentTextView.attributedText = text
        contentTextView.selectedRange = selectedRange
    }
}

// MARK: - StoryboardLoadable

extension NewThreadViewController: StoryboardLoadable {}

// MARK: - YYTextViewDelegate

extension NewThreadViewController: YYTextViewDelegate {
    func textViewShouldBeginEditing(_ textView: YYTextView) -> Bool {
        activeTextView = textView
        return true
    }
    
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
            titleVariable.value = textView.text ?? ""
        } else {
            contentVariable.value = textView.text ?? ""
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
