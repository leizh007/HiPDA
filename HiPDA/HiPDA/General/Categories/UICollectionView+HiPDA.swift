//
//  UICollectionView+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/18.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

extension UICollectionView {
    /// 注册Nib
    ///
    /// - parameter _: Nib对应的class类型
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let Nib = UINib(nibName: T.NibName, bundle: nil)
        register(Nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    /// 注册class
    ///
    /// - parameter _: Cell的class类型
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    /// 获取ReusableCell，必须提前已注册.
    /// - 使用方法：let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TestTableViewCell
    ///
    /// - parameter indexPath: 下标
    ///
    /// - returns: 返回制定类型的cell
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}
