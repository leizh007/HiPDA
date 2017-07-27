//
//  LoginViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MessageUI

/// 登录成功后的回调
typealias LoggedInCompletionHandler = (Account) -> Void

/// 默认的容器视图的顶部constraint
private let kDefaultContainerTopConstraintValue = CGFloat(44.0)

/// 登录的ViewController
class LoginViewController: BaseViewController, StoryboardLoadable {    
    /// 分割线的高度constriant
    @IBOutlet private var seperatorsHeightConstraint: [NSLayoutConstraint]!
    
    /// 点击背景的手势识别
    @IBOutlet private var tapBackground: UITapGestureRecognizer!
    
    /// 显示密码被点击
    @IBOutlet private var tapShowPassword: UITapGestureRecognizer!
    
    /// 输入密码的TextField
    @IBOutlet private weak var passwordTextField: UITextField!
    
    /// 隐藏显示密码的ImageView
    @IBOutlet private weak var hidePasswordImageView: UIImageView!
    
    /// 输入姓名的TextField
    @IBOutlet private weak var nameTextField: UITextField!
    
    /// 输入答案的TextField
    @IBOutlet private weak var answerTextField: UITextField!
    
    /// 安全问题Button
    @IBOutlet private weak var questionButton: UIButton!
    
    /// 是否可取消
    var cancelable = false
    
    /// 取消按钮
    @IBOutlet private weak var cancelButton: UIButton!
    
    /// 安全问题的driver
    private var questionDriver: Driver<Int>!
    
    /// 回答的driver
    private var answerDriver: Driver<String>!
    
    /// 登录按钮
    @IBOutlet private weak var loginButton: UIButton!
    
    /// 容器视图的顶部constraint
    @IBOutlet private weak var containerTopConstraint: NSLayoutConstraint!
    
    /// 登录成功后的回调
    var loggedInCompletion: LoggedInCompletionHandler?
    
    var cancelCompletion: ((Void) -> Void)?
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.isHidden = !cancelable
        
        configureKeyboard()
        configureQuestionButton()
        configureTapGestureRecognizer()
        configureTextFields()
        configureViewModel()
    }
    
    @IBAction func adviseButtonPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([C.URL.authorEmail])
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto:\(C.URL.authorEmail)")!)
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        URLDispatchManager.shared.linkActived("https://www.hi-pda.com/forum/tobenew.php")
    }
    
    override func setupConstraints() {
        for heightConstraint in seperatorsHeightConstraint {
            heightConstraint.constant = 1.0 / UIScreen.main.scale
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - private method
    
    /// 设置手势识别
    private func configureTapGestureRecognizer() {
        tapShowPassword.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let isSecureTextEntry = self.passwordTextField.isSecureTextEntry
            self.passwordTextField.isSecureTextEntry = !isSecureTextEntry
            let image: UIImage
            switch isSecureTextEntry {
            case true:
                image = #imageLiteral(resourceName: "login_password_show")
            case false:
                image = #imageLiteral(resourceName: "login_password_hide")
            }
            
            UIView.transition(with: self.hidePasswordImageView,
                              duration: C.UI.animationDuration,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.hidePasswordImageView.image = image
            }, completion: nil)
        }).addDisposableTo(disposeBag)
    }
    
    /// 设置TextFields
    private func configureTextFields() {
        let textValue = Variable("")
        (passwordTextField.rx.textInput <-> textValue).addDisposableTo(disposeBag)
        textValue.asObservable().map { $0.characters.count == 0 }
            .bindTo(hidePasswordImageView.rx.isHidden).addDisposableTo(disposeBag)
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.answerTextField.becomeFirstResponder()
        }).addDisposableTo(disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.passwordTextField.becomeFirstResponder()
        }).addDisposableTo(disposeBag)
        
        answerTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.answerTextField.resignFirstResponder()
        }).addDisposableTo(disposeBag)
    }
    
    /// 配置安全问题的Button
    private func configureQuestionButton() {
        let questionVariable = Variable(0)
        let answerVariable = Variable("")
        (answerTextField.rx.textInput <-> answerVariable).addDisposableTo(disposeBag)
        
        questionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let questions = LoginViewModel.questions
            let pickerActionSheetController = PickerActionSheetController.load(from: .views)
            pickerActionSheetController.pickerTitles = questions
            pickerActionSheetController.initialSelelctionIndex = questions.index(of: self.questionButton.title(for: .normal)!)
            pickerActionSheetController.selectedCompletionHandler = { [unowned self] (index) in
                self.dismiss(animated: false, completion: nil)
                if let index = index, let title = questions.safe[index] {
                    self.questionButton.setTitle(title, for: .normal)
                    questionVariable.value = index
                }
            }
            pickerActionSheetController.modalPresentationStyle = .overCurrentContext
            self.present(pickerActionSheetController, animated: false, completion: nil)
        }).addDisposableTo(disposeBag)
        
        questionDriver = questionVariable.asDriver()
        questionDriver.drive(onNext: { [weak self] (index) in
            guard let `self` = self else { return }
            if index == 0 {
                self.answerTextField.isEnabled = false
                self.passwordTextField.returnKeyType = .done
            } else {
                self.answerTextField.isEnabled = true
                self.passwordTextField.returnKeyType = .next
            }
            
            answerVariable.value = ""
        }).addDisposableTo(disposeBag)
        
        answerDriver = answerVariable.asDriver()
    }
    
    /// 处理键盘相关
    private func configureKeyboard() {
        let dismissEvents: [Observable<Void>] = [
            tapBackground.rx.event.map { _ in () },
            questionButton.rx.tap.map { _ in () },
            cancelButton.rx.tap.map { _ in () },
            loginButton.rx.tap.map { _ in () }
        ]
        
        Observable.from(dismissEvents).merge().subscribe(onNext: { [weak self] _ in
            self?.nameTextField.resignFirstResponder()
            self?.passwordTextField.resignFirstResponder()
            self?.answerTextField.resignFirstResponder()
        }).addDisposableTo(disposeBag)
        
        KeyboardManager.shared.keyboardChanged.drive(onNext: { [weak self, unowned keyboardManager = KeyboardManager.shared] transition in
            guard let `self` = self else { return }
            guard transition.toVisible.boolValue else {
                self.containerTopConstraint.constant = kDefaultContainerTopConstraintValue
                UIView.animate(withDuration: transition.animationDuration, delay: 0.0, options: transition.animationOption, animations: { 
                    self.view.layoutIfNeeded()
                }, completion: nil)
                return
            }
            guard let textField = self.activeTextField() else { return }
            let keyboardFrame = keyboardManager.convert(transition.toFrame, to: self.view)
            let textFieldFrame = textField.convert(textField.frame, to: self.view)
            let heightGap = textFieldFrame.origin.y + textFieldFrame.size.height - keyboardFrame.origin.y
            let containerTopConstraintConstant = heightGap > 0 ? self.containerTopConstraint.constant - heightGap : kDefaultContainerTopConstraintValue
            self.containerTopConstraint.constant = containerTopConstraintConstant
            UIView.animate(withDuration: transition.animationDuration, delay: 0.0, options: transition.animationOption, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }).addDisposableTo(disposeBag)
    }
    
    /// 配置ViewModel相关信息
    func configureViewModel() {
        let nameVariable = Variable("")
        let passwordVariable = Variable("")
        (nameTextField.rx.textInput <-> nameVariable).addDisposableTo(disposeBag)
        (passwordTextField.rx.textInput <-> passwordVariable).addDisposableTo(disposeBag)
        
        let viewModel = LoginViewModel(username: nameVariable.asDriver(),
                                       password: passwordVariable.asDriver(),
                                       questionid: questionDriver,
                                       answer: answerDriver,
                                       loginTaps: loginButton.rx.tap.asDriver())
        viewModel.loginEnabled.drive(loginButton.rx.isEnabled).addDisposableTo(disposeBag)
        
        viewModel.loggedIn.drive(onNext: { [unowned self] result in
            self.hidePromptInformation()
            switch result {
            case .success(let account):
                self.showPromptInformation(of: .success("登录成功"))
                Settings.shared.shouldAutoLogin = true
                delay(seconds: 1.0) {
                    self.loggedInCompletion?(account)
                }
            case .failure(let error):
                self.showPromptInformation(of: .failure("\(error)"))
            }
        }).addDisposableTo(disposeBag)
        
        loginButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.showPromptInformation(of: .loading("正在登录..."))
        }).addDisposableTo(disposeBag)
        
        cancelButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.cancelCompletion?()
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        if let account = Settings.shared.lastLoggedInAccount {
            nameVariable.value = account.name
            passwordVariable.value = account.password
        }
    }
    
    /// 找到激活的textField
    ///
    /// - returns: 返回first responser的textField
    private func activeTextField() -> UITextField? {
        for textField in [nameTextField, passwordTextField, answerTextField] {
            if textField!.isFirstResponder {
                return textField
            }
        }
        
        return nil
    }
}

extension LoginViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
