//
//  SendMessageViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/25.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift

class SendShortMessageViewController: BaseViewController {
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var containerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1).cgColor
        configureKeyboard()
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

extension SendShortMessageViewController: StoryboardLoadable { }
