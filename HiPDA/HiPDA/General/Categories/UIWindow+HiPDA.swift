//
//  UIWindow+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/27.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

#if DEBUG
import FLEX

extension UIWindow {
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            if FLEXManager.shared().isHidden {
                FLEXManager.shared().showExplorer()
            }
            if FPSAssistiveTouch.shared.isHidden {
                FPSAssistiveTouch.shared.show()
            } else {
                FPSAssistiveTouch.shared.dismiss()
            }
        }
    }
}
#endif
