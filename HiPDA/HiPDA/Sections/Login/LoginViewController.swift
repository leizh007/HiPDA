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

/// 动画持续时间
private let kAnimationDuration = 0.25

/// 登录的ViewController
class LoginViewController: UIViewController, StoryboardLoadable {
    /// disposeBag
    private let _disposeBag = DisposeBag()
    
    /// 安全问题数组
    private let questions = [
        "安全问题",
        "母亲的名字",
        "爷爷的名字",
        "父亲出生的城市",
        "您其中一位老师的名字",
        "您个人计算机的型号",
        "您最喜欢的餐馆名称",
        "驾驶执照的最后四位数字"
    ]
    
    /// 分割线的高度constriant
    @IBOutlet var seperatorsHeightConstraint: [NSLayoutConstraint]!
    
    /// 点击背景的手势识别
    @IBOutlet var tapBackground: UITapGestureRecognizer!
    
    /// 显示更多用户名被点击
    @IBOutlet var tapShowMoreName: UITapGestureRecognizer!
    
    /// 显示密码被点击
    @IBOutlet var tapShowPassword: UITapGestureRecognizer!
    
    /// 显示更多用户名的imageView
    @IBOutlet weak var showMoreNameImageView: UIImageView!
    
    /// 输入密码的TextField
    @IBOutlet weak var passwordTextField: UITextField!
    
    /// 隐藏显示密码的ImageView
    @IBOutlet weak var hidePasswordImageView: UIImageView!
    
    /// 输入姓名的TextField
    @IBOutlet weak var nameTextField: UITextField!
    
    /// 输入答案的TextField
    @IBOutlet weak var answerTextField: UITextField!
    
    /// 安全问题Button
    @IBOutlet weak var questionButton: UIButton!
    
    /// 是否可取消
    var cancelable = false
    
    /// 取消按钮
    @IBOutlet weak var cancelButton: UIButton!
    
    /// 安全问题的driver
    var questionDriver: Driver<Int>!
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for heightConstraint in seperatorsHeightConstraint {
            heightConstraint.constant = 1.0 / UIScreen.main.scale
        }
        cancelButton.isHidden = !cancelable
        
        // FIXME: - fix login view mdel initialization
        let viewModel = LoginViewModel()
        showMoreNameImageView.isHidden = viewModel.isShowMoreNameImageViewHidden
        
        configureQuestionButton()
        configureTapGestureRecognizer()
        configureTextFields()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - private method
    
    /// 设置手势识别
    private func configureTapGestureRecognizer() {
        tapBackground.rx.event.subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).addDisposableTo(_disposeBag)
        
        tapShowMoreName.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            self.view.endEditing(true)
            self.showMoreNameImageView.layer.rotate(angle: M_PI, duration: kAnimationDuration)
         }).addDisposableTo(_disposeBag)
        
        tapShowPassword.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            self.view.endEditing(true)
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
                              duration: kAnimationDuration,
                              options: .transitionCrossDissolve,
                              animations: { 
                                self.hidePasswordImageView.image = image
                }, completion: nil)
            
        }).addDisposableTo(_disposeBag)
    }
    
    /// 设置TextFields
    private func configureTextFields() {
        let textValue = Variable("")
        _ = passwordTextField.rx.textInput <-> textValue
        textValue.asObservable().map { $0.characters.count == 0 }
            .bindTo(hidePasswordImageView.rx.hidden).addDisposableTo(_disposeBag)
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.answerTextField.becomeFirstResponder()
        }).addDisposableTo(_disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidBegin).subscribe(onNext: { [weak self] _ in
            self?.showMoreNameImageView.layer.transform = CATransform3DIdentity
        }).addDisposableTo(_disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.passwordTextField.becomeFirstResponder()
        }).addDisposableTo(_disposeBag)
        
        answerTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).addDisposableTo(_disposeBag)
    }
    
    /// 配置安全问题的Button
    private func configureQuestionButton() {
        let questionVariable = Variable(0)
        
        questionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            self.view.endEditing(true)
            let pickerActionSheetController = PickerActionSheetController.load(from: UIStoryboard.main)
            pickerActionSheetController.pickerTitles = self.questions
            pickerActionSheetController.initialSelelctionIndex = self.questions.index(of: self.questionButton.title(for: .normal)!)
            pickerActionSheetController.selectedCompletionHandler = { [unowned self] (index) in
                self.dismiss(animated: false, completion: nil)
                if let index = index, let title = self.questions.safe[index] {
                    self.questionButton.setTitle(title, for: .normal)
                    questionVariable.value = index
                }
            }
            pickerActionSheetController.modalPresentationStyle = .overCurrentContext
            self.present(pickerActionSheetController, animated: false, completion: nil)
        }).addDisposableTo(_disposeBag)
        
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
            self.answerTextField.text = ""
        }).addDisposableTo(_disposeBag)
    }
}
