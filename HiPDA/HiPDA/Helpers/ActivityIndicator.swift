//
//  ActivityIndicator.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/10.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// ActivityToken
private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    //MARK: - Disposable
    
    func dispose() {
        _dispose.dispose()
    }
    
    // MARK: - ObservableConvertibleType
    
    func asObservable() -> Observable<E> {
        return _source.asObservable()
    }
}


/// 检测活动的状态
///
/// 只要有至少一个序列在执行，将会发送 `true`. 所有活动结束的时候，发送 `false`.
class ActivityIndicator: SharedSequenceConvertibleType {
    typealias E = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let _lock = NSRecursiveLock()
    private let _variable = Variable(0)
    private let _loading: Driver<Bool>
    
    init() {
        _loading = _variable.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func track<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
        return Observable.using({ () -> ActivityToken<O.E> in
                self.increment()
                return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
            }, observableFactory: { (t) -> Observable<O.E> in
                return t.asObservable()
        })
    }
    
    private func increment() {
        _lock.lock()
        _variable.value += 1
        _lock.unlock()
    }
    
    private func decrement() {
        _lock.lock()
        _variable.value -= 1
        _lock.unlock()
    }
    
    // MARK: - DriverConvertibleType
    public func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return _loading
    }
}

extension ObservableConvertibleType {
    func track(_ activityIndicator: ActivityIndicator) -> Observable<E> {
        return activityIndicator.track(self)
    }
}
