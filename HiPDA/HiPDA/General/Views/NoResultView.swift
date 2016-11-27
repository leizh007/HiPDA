//
//  NoResultView.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// BaseTableView没有数据时候的显示视图
class NoResultView: UIView {
    /// 描述信息的label
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    /// activityIndicator
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// TableView的状态
    var status = BaseTableViewStatus.loading {
        didSet {
            struct Description {
                static let noResult = "暂无数据"
                static let tapToLoad = "点击屏幕，重新加载"
            }
            switch status {
            case .loading:
                isLoading = true
            case .noResult:
                isLoading = false
                descriptionLabel.text = Description.noResult
            case .tapToLoad:
                isLoading = false
                descriptionLabel.text = Description.tapToLoad
            default:
                break
            }
        }
    }
    
    /// 是否正在加载
    private var isLoading = false {
        didSet {
            activityIndicator.isHidden = !isLoading
            descriptionLabel.isHidden = isLoading
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: - XibLoadable

extension NoResultView: XibLoadable {
    
}
