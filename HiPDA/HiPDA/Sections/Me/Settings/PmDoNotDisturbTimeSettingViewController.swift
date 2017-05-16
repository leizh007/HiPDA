//
//  PmDoNotDisturbTimeSettingViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/12/18.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 设置完消息免打扰时间的回调block
typealias PmDoNotDisturbTimeSettingCompletionHandler = (PmDoNotDisturbTime, PmDoNotDisturbTime) -> Void

/// 容器试图的高度
fileprivate let kContainerViewHeight: CGFloat = 261.0

/// 动画持续时间
fileprivate let kAnimationDuration = 0.25

/// 消息免打扰起始时间的设置VC
class PmDoNotDisturbTimeSettingViewController: BaseViewController {
    /// 开始时间
    var fromTime: PmDoNotDisturbTime!
    
    /// 结束时间
    var toTime: PmDoNotDisturbTime!
    
    /// 设置完后的回调block
    var completion: PmDoNotDisturbTimeSettingCompletionHandler?
    
    /// 开始时间的pickerView
    @IBOutlet fileprivate weak var fromTimePickerView: UIPickerView!
    
    /// 开始时间的label
    @IBOutlet fileprivate weak var fromTimeDescriptionLabel: UILabel!
    
    /// 结束时间的pickerView
    @IBOutlet fileprivate weak var toTimePickerView: UIPickerView!
    
    /// 结束时间的label
    @IBOutlet fileprivate weak var toTimeDescriptionLabel: UILabel!
    
    /// 容器试图的底部constraint
    @IBOutlet fileprivate weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    /// 分割线的高度constraint
    @IBOutlet fileprivate weak var seperatorLineHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePickerViews()
        seperatorLineHeightConstraint.constant = 1.0 / C.UI.screenScale
        containerViewBottomConstraint.constant = -kContainerViewHeight
        useCustomViewControllerTransitioningAnimator = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        containerViewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: kAnimationDuration) {
            self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            self.view.layoutIfNeeded()
            self.fromTimeDescriptionLabel.text = String(format: "开始时间: %d:%02d", self.fromTime.hour, self.fromTime.minute)
            self.toTimeDescriptionLabel.text = String(format: "结束时间: %d:%02d", self.toTime.hour, self.toTime.minute)
        }
        
        fromTimePickerView.selectRow(fromTime.hour, inComponent: 0, animated: true)
        fromTimePickerView.selectRow(fromTime.minute, inComponent: 1, animated: true)
        toTimePickerView.selectRow(toTime.hour, inComponent: 0, animated: true)
        toTimePickerView.selectRow(toTime.minute, inComponent: 1, animated: true)
    }
    
    /// 设置pickerView
    private func configurePickerViews() {
        let timeFromPickerViewSelection = { (time : PmDoNotDisturbTime, row : Int, component : Int) -> PmDoNotDisturbTime in
            return component == 0 ? (hour: row, minute: time.minute) : (hour: time.hour, minute: row)
        }
        
        fromTimePickerView.rx.itemSelected
            .map { [unowned self] (row, component) in
                return timeFromPickerViewSelection(self.fromTime, row, component)
            }
            .do(onNext: { [unowned self] time in
                self.fromTime = time
            })
            .map {
                return String(format: "开始时间: %d:%02d", $0.hour, $0.minute)
            }
            .bindTo(self.fromTimeDescriptionLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        toTimePickerView.rx.itemSelected
            .map { [unowned self] (row, component) in
                return timeFromPickerViewSelection(self.toTime, row, component)
            }
            .do(onNext: { [unowned self] time in
                self.toTime = time
            })
            .map {
                return String(format: "结束时间: %d:%02d", $0.hour, $0.minute)
            }
            .bindTo(self.toTimeDescriptionLabel.rx.text)
            .addDisposableTo(disposeBag)
    }
    
    /// 取消
    private func cancel() {
        containerViewBottomConstraint.constant = -kContainerViewHeight
        UIView.animate(withDuration: kAnimationDuration, animations: {
            self.view.backgroundColor = UIColor.clear
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - Button Action
    
    /// 取消按钮被点击
    ///
    /// - Parameter sender: 取消按钮
    @IBAction fileprivate func cancelButtonPressed(_ sender: Any) {
        cancel()
    }
    
    /// 确认按钮被点击
    ///
    /// - Parameter sender: 确认按钮
    @IBAction fileprivate func confirmButtonPressed(_ sender: Any) {
        completion?(self.fromTime, self.toTime)
        containerViewBottomConstraint.constant = -kContainerViewHeight
        UIView.animate(withDuration: kAnimationDuration, animations: {
            self.view.backgroundColor = UIColor.clear
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    /// 背景被点击
    ///
    /// - Parameter sender: 背景按钮
    @IBAction fileprivate func backgroundButtonPressed(_ sender: Any) {
        cancel()
    }
}

// MARK: -  UIPickerViewDelegate

extension PmDoNotDisturbTimeSettingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}

// MARK: - UIPickerViewDataSource

extension PmDoNotDisturbTimeSettingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 24 : 60
    }
}
