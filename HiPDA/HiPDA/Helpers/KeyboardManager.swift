//
//  KeyboardManager.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/15.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import YYKeyboardManager
import RxSwift
import RxCocoa

/// 默认的键盘Transition
private let kDefaultKeyboardTransision = YYKeyboardTransition(fromVisible: false,
                                                              toVisible: false,
                                                              fromFrame: .zero,
                                                              toFrame: .zero,
                                                              animationDuration: 0.0,
                                                              animationCurve: .easeInOut,
                                                              animationOption: [])

/// 管理键盘的出现和隐藏
class KeyboardManager: NSObject {
    /// 单例
    static let shared = KeyboardManager()
    
    /// 键盘变换的Driver
    let keyboardChanged: Driver<YYKeyboardTransition>
    
    /// 键盘变换的Variable
    fileprivate let _keyboardChangedVariable = Variable(kDefaultKeyboardTransision)
    
    /// YYKeyboardManager
    private let _keyboardManager = YYKeyboardManager.default()
    
    /// 键盘所在的Window
    var keyboardWindow: UIWindow? {
        return _keyboardManager.keyboardWindow
    }
    
    /// 键盘所在的View
    var keyboardView: UIView? {
        return _keyboardManager.keyboardView
    }
    
    /// 键盘是否可见
    var isKeyboardVisible: Bool {
        return _keyboardManager.isKeyboardVisible
    }
    
    /// 键盘的frame
    var keyboardFrame: CGRect {
        return _keyboardManager.keyboardFrame
    }
    
    /// 将键盘的frame转换到特定view或window中
    ///
    /// - parameter rect: 待转换的frame
    /// - parameter view: 目标view
    ///
    /// - returns: 返回转换好的frame
    func convert(_ rect: CGRect, to view: UIView?) -> CGRect {
        return _keyboardManager.convert(rect, to: view)
    }
    
    override init() {
        keyboardChanged = _keyboardChangedVariable.asDriver()
        super.init()
        _keyboardManager.add(self)
    }
}

// MARK: - YYKeyboardObserver

extension KeyboardManager: YYKeyboardObserver {
    func keyboardChanged(with transition: YYKeyboardTransition) {
        _keyboardChangedVariable.value = transition
    }
}
