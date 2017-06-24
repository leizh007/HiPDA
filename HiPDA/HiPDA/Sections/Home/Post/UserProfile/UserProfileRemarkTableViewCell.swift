//
//  UserProfileRemarkTableViewCell.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/24.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol UserProfileRemarkDelegate: class {
    func remarkDidChange(_ remark: String?)
}

class UserProfileRemarkTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var remarkTextField: UITextField!
    weak var delegate: UserProfileRemarkDelegate?
    var remark: String? {
        get {
            return remarkTextField.text
        }
        set {
            remarkTextField.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        remarkTextField.delegate = self
    }
}

extension UserProfileRemarkTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let remark = text.replacingCharacters(in: range, with: string)
        delegate?.remarkDidChange(remark.isEmpty ? nil : remark)
        
        return true
    }
}
