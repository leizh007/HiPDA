//
//  UserProfileViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserProfileViewModel {
    private var disposeBag = DisposeBag()
    fileprivate var model = UserProfileModel(sections: [])
    fileprivate var oldRemark: String?
    fileprivate var oldIsBlocked = false
    let uid: Int
    var name: String = ""
    init(uid: Int) {
        self.uid = uid
    }
    
    func refresh(completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        disposeBag = DisposeBag()
        HiPDAProvider.request(.userProfile(uid: uid))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { try UserProfileModel.createInstance(from: $0) }
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .next(let model):
                    self?.model = model
                    self?.name = UserProfileViewModel.userName(model)
                    self?.configureRemarkAndBlock()
                    completion(.success(()))
                case .error(let error):
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    func addFriend(completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        NetworkUtilities.addFriend(uid: uid, completion: completion)
    }
    
    fileprivate static func userName(_ model: UserProfileModel) -> String {
        for case let .account(account) in model.sections {
            return account.items.first?.name ?? ""
        }
        return ""
    }
    
    fileprivate func configureRemarkAndBlock() {
        oldRemark = Settings.shared.userRemarkDictionary[name]
        oldIsBlocked = Settings.shared.userBlockList.contains(name)
    }
    
    var remark: String? {
        get {
            return Settings.shared.userRemarkDictionary[name]
        }
        set {
            Settings.shared.userRemarkDictionary[name] = newValue
        }
    }
    
    var blockTitle: String {
        return Settings.shared.userBlockList.contains(name) ? "移出黑名单" : "加入黑名单"
    }
    
    func changeBlockState() {
        if let index = Settings.shared.userBlockList.index(where: { $0 == name }) {
            Settings.shared.userBlockList.remove(at: index)
        } else {
            Settings.shared.userBlockList.append(name)
        }
    }
    
    func didUserProfileChanged() -> Bool {
        return !(oldRemark == Settings.shared.userRemarkDictionary[name] &&
            oldIsBlocked == Settings.shared.userBlockList.contains(name))
    }
}

// MARK: - DataSource

extension UserProfileViewModel {
    func numberOfSections() -> Int {
        return model.sections.count
    }
    
    func numberOfItems(at section: Int) -> Int {
        let section = model.sections[section]
        return section.isCollapsed ? 0 : section.items.count
    }
    
    func section(at index: Int) -> ProfileSectionType {
        return model.sections[index]
    }
    
    func changeSectionHeaderCollapse(at index: Int) {
        model.changeSectionHeaderCollapse(at: index)
    }
}

private func ==<T: Equatable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let(l?, r?):
        return l == r
    case (nil, nil):
        return true
    default:
        return false
    }
}

