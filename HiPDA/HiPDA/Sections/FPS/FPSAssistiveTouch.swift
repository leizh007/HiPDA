//
//  FPSAssistiveTouch.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/30.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 显示FPS辅助试图
class FPSAssistiveTouch: UIWindow {
    // 当frame的宽或高为0的时候，设置bounds的size为改size
    private static let size = CGSize(width: 55, height: 20)
    
    // 展示fps的Label
    private let fpsLabel = FPSLabel(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: FPSAssistiveTouch.size.width,
                                                  height: FPSAssistiveTouch.size.height))
    
    private static let shared: FPSAssistiveTouch = {
        let fps = FPSAssistiveTouch(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 0,
                                                  height: 0))
        fps.backgroundColor = UIColor.clear
        fps.windowLevel = UIWindowLevelNormal + 1001
        fps.isHidden = true
        
        return fps
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: kScreenWidth * 2.0 / 3.0,
                                 y: 0,
                                 width: FPSAssistiveTouch.size.width,
                                 height: FPSAssistiveTouch.size.height))
        
        addSubview(fpsLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Touch Events
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let mainWindow = UIApplication.shared.windows[0];
        let point = touch?.location(in: mainWindow)
        
        FPSAssistiveTouch.shared.center = point ?? FPSAssistiveTouch.shared.center
        
        var center = FPSAssistiveTouch.shared.center
        if center.x < FPSAssistiveTouch.size.width / 2.0 {
            center.x = FPSAssistiveTouch.size.width / 2.0
        }
        if center.x > kScreenWidth - FPSAssistiveTouch.size.width / 2.0 {
            center.x = kScreenWidth - FPSAssistiveTouch.size.width / 2.0
        }
        if center.y < FPSAssistiveTouch.size.height / 2.0 {
            center.y = FPSAssistiveTouch.size.height / 2.0
        }
        if center.y > kScreenHeigh - FPSAssistiveTouch.size.height / 2.0 {
            center.y = kScreenHeigh - FPSAssistiveTouch.size.height / 2.0
        }
        
        FPSAssistiveTouch.shared.center = center
    }
    
    // MARK: - Class Methods
    
    /// 展示
    static func show() {
        FPSAssistiveTouch.shared.isHidden = false
    }
    
    /// 隐藏
    static func dismiss() {
        FPSAssistiveTouch.shared.isHidden = true
    }
}
