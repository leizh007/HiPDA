//
//  PromptInformationShowable.swift
//  HiPDA
//
//  Created by leizh007 on 2016/11/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation
import MBProgressHUD

/// ProgressHUD的样式
///
/// - loading: 正在加载
/// - success: 成功
/// - failure: 失败
enum ProgressHUDStyle {
    case loading(String)
    case success(String)
    case failure(String)
}

protocol PromptInformationShowable {
    /// 展示提示信息
    ///
    /// - parameter style: 提示信息的样式
    func showPromptInformation(of style: ProgressHUDStyle, in view: UIView?)
    
    /// 隐藏提示信息
    func hidePromptInformation(in view: UIView?)
}

extension PromptInformationShowable where Self: UIViewController {
    /// 展示提示信息
    ///
    /// - parameter style: 提示信息的样式
    func showPromptInformation(of style: ProgressHUDStyle, in view: UIView? = nil) {
        let viewToShowedIn: UIView
        if let view = view {
            viewToShowedIn = view
        } else {
            viewToShowedIn = ancestor.view
        }
        
        let hud = MBProgressHUD.showAdded(to: viewToShowedIn, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8)
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        hud.contentColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        hud.label.numberOfLines = 0
        
        func custom(of hud: MBProgressHUD, with image: UIImage, title: String, delay: TimeInterval) {
            hud.mode = .customView
            hud.label.text = title
            hud.customView = UIImageView(image: image)
            hud.hide(animated: true, afterDelay: delay)
        }
        
        switch style {
        case .loading(let value):
            hud.label.text = value 
        case .success(let value):
            custom(of: hud, with: #imageLiteral(resourceName: "hud_success"), title: value, delay: 1.0)
        case .failure(let value):
            custom(of: hud, with: #imageLiteral(resourceName: "hud_failure"), title: value, delay: 1.5)
        }
    }
    
    /// 隐藏提示信息
    func hidePromptInformation(in view: UIView? = nil) {
        let viewToShowedIn: UIView
        if let view = view {
            viewToShowedIn = view
        } else {
            viewToShowedIn = ancestor.view
        }
        MBProgressHUD.hide(for: viewToShowedIn, animated: true)
    }
}

extension UIViewController: PromptInformationShowable {

}
