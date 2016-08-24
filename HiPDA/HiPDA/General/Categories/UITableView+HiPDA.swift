//
//  UITableView+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

extension UITableView {
    /// 注册Nib
    ///
    /// - parameter _: Nib对应的class类型
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let Nib = UINib(nibName: T.NibName, bundle: nil)
        register(Nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    /// 注册class
    ///
    /// - parameter _: Cell的class类型
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    /// 获取ReusableCell，必须提前已注册.
    /// - 使用方法：let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TestTableViewCell
    ///
    /// - parameter indexPath: 下标
    ///
    /// - returns: 返回制定类型的cell
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}
