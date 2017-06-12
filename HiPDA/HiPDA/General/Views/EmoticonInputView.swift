//
//  EmoticonInputView.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/12.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

private enum Constant {
    static let viewHeight = CGFloat(216.0)
}

class EmoticonInputView: UIView {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: Constant.viewHeight))
    }
}
