//
//  SettingsRouter.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/9.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit
import Perform
import RxSwift
import RxCocoa

/// 创建SettingsSegue错误
///
/// - unRecognizedIndexPath: indexPath无法识别
enum SettingsSugueError: Error {
    case unRecognizedIndexPath
}

enum SettingsSegue: String {
    case userBlock = "黑名单列表"
    case threadBlock = "帖子过滤词组"
    case threadAttention = "帖子关注词组"
    
    init(indexPath: IndexPath) throws {
        switch (indexPath.section, indexPath.row) {
        case (2, 1):
            self = .userBlock
        case (3, 1):
            self = .threadBlock
        case (4, 1):
            self = .threadAttention
        default:
            throw SettingsSugueError.unRecognizedIndexPath
        }
    }
}

extension Segue {
    /// 编辑词组
    static var editWords: Segue<EditWordListViewController> {
        return .init(identifier: "EditWords")
    }
}

/// 设置路由
struct SettingsRouter {
    /// disposeBag
    private let disposeBag = DisposeBag()
    
    /// viewController
    weak var viewController: SettingsViewController?
    
    init(viewController: SettingsViewController) {
        self.viewController = viewController
    }
    
    /// 处理item选择
    ///
    /// - Parameter indexPath: 选择的下标
    func handleSelection(for indexPath: IndexPath) {
        guard let settingsSegue = try? SettingsSegue(indexPath: indexPath) else { return }
        switch settingsSegue {
        case .userBlock:
            fallthrough
        case .threadBlock:
            fallthrough
        case .threadAttention:
            gotoEditWordsViewController(with: settingsSegue)
        }
    }
    
    /// 跳转到编辑词组页面
    ///
    /// - Parameter settingsSegue: 页面类型
    private func gotoEditWordsViewController(with settingsSegue: SettingsSegue) {
        guard let viewController = self.viewController else { return }
        let words: [String]
        switch settingsSegue {
        case .userBlock:
            words = viewController.viewModel.userBlockList
        case .threadBlock:
            words = viewController.viewModel.threadBlockWordList
        case .threadAttention:
            words = viewController.viewModel.threadAttentionWordList
        }
        
        viewController.perform(.editWords) { editWordsViewController in
            editWordsViewController.title = settingsSegue.rawValue
            editWordsViewController.words = words
            editWordsViewController.completion = { words in
                switch settingsSegue {
                case .userBlock:
                    self.viewController?.viewModel.userBlockList = words
                case .threadBlock:
                    self.viewController?.viewModel.threadBlockWordList = words
                case .threadAttention:
                    self.viewController?.viewModel.threadAttentionWordList = words
                }
            }
        }
    }
}
