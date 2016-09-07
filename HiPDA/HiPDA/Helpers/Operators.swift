//
//  Operators.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/7.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <->: DefaultPrecedence

/// 双向绑定
///
/// - parameter textInput: 待绑定的输入
/// - parameter variable:  待绑定的变量
///
/// - returns: 返回Disposable
func <-> <Base: UITextInput>(textInput: TextInput<Base>, variable: Variable<String>) -> Disposable {
    let bindToUIDisposable = variable.asObservable().bindTo(textInput.text)
    let bindToVariable = textInput.text.subscribe(onNext: { [weak base = textInput.base] n in
        guard let base = base else { return }
        let nonMarkedTextValue = base.nonMarkedText
        if let nonMarkedTextValue = nonMarkedTextValue, nonMarkedTextValue != variable.value {
            variable.value = nonMarkedTextValue
        }
    }, onCompleted: {
         bindToUIDisposable.dispose()
    })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

/// 双向绑定
///
/// - parameter property: 待绑定的输入流
/// - parameter variable: 待绑定的变量
///
/// - returns: 返回Disposable
func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    if T.self == String.self {
#if DEBUG
        fatalError("See more information here: https://github.com/ReactiveX/RxSwift/issues/649")
#endif
    }
    
    let bindToUIDisposable = variable.asObservable().bindTo(property)
    let bindToVariable = property.subscribe(onNext: { n in
        variable.value = n
    }, onCompleted: {
        bindToUIDisposable.dispose()
    })
    
    return Disposables.create(bindToUIDisposable, bindToVariable)
}
