//
//  ReusableView.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/23.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 可重用View
protocol ReusableView: class {
    
}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

extension UITableViewCell: ReusableView {
    
}

extension UICollectionViewCell: ReusableView {
    
}
