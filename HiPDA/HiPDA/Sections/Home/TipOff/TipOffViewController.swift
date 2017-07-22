//
//  TipOffViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TipOffViewController: BaseViewController {
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tipOffLabel: UILabel!
    var user: User!
    fileprivate var viewModel: TipOffViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1).cgColor
        tipOffLabel.text = "举报: \(user.name)"
        configureKeyboard()
        viewModel = TipOffViewModel(user: user)
        textView.rx.text.orEmpty.map { !$0.isEmpty }.bindTo(sendButton.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        show()
    }
    
    fileprivate func configureKeyboard() {
        KeyboardManager.shared.keyboardChanged.drive(onNext: { [weak self, unowned keyboardManager = KeyboardManager.shared] transition in
            guard let `self` = self else { return }
            guard transition.toVisible.boolValue else {
                self.containerBottomConstraint.constant = -176
                UIView.animate(withDuration: transition.animationDuration, delay: 0.0, options: transition.animationOption, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                return
            }
            let keyboardFrame = keyboardManager.convert(transition.toFrame, to: self.view)
            self.containerBottomConstraint.constant = keyboardFrame.size.height
            UIView.animate(withDuration: transition.animationDuration, delay: 0.0, options: transition.animationOption, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }).addDisposableTo(disposeBag)
    }
    
    @IBAction fileprivate func cancelButtonPressed(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction fileprivate func sendButtonPressed(_ sender: UIButton) {
        guard let window = UIApplication.shared.windows.last else { return }
        showPromptInformation(of: .loading("正在发送..."), in: window)
        viewModel.sendMessage(textView.text ?? "") { [weak self] result in
            self?.hidePromptInformation(in: window)
            switch result {
            case .success(let info):
                self?.showPromptInformation(of: .success(info), in: window)
                delay(seconds: 0.25) {
                    self?.dismiss()
                }
            case .failure(let error):
                self?.showPromptInformation(of: .failure(error.localizedDescription), in: window)
            }
        }
    }
    
    @IBAction fileprivate func backgroundDidTapped(_ sender: Any) {
        dismiss()
    }
    
    private func show() {
        textView.becomeFirstResponder()
        UIView.animate(withDuration: C.UI.animationDuration) {
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        }
    }
    
    private func dismiss() {
        view.endEditing(true)
        UIView.animate(withDuration: C.UI.animationDuration, animations: {
            self.view.backgroundColor = .clear
        }, completion: { _ in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
}

// MARK: - StoryboardLoadable

extension TipOffViewController: StoryboardLoadable { }
