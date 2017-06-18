//
//  MessaegShowable.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

protocol MessaegShowable {
    func showMessage(title: String?, message: String?)
}

extension MessaegShowable where Self: UIViewController {
    func showMessage(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
}

extension UIViewController: MessaegShowable { }
