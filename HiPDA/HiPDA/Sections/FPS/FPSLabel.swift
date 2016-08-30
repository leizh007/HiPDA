//
//  FPSLabel.swift
//  HiPDA
//
//  Created by leizh007 on 16/8/30.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 展示FPS的Label
class FPSLabel: UILabel {
    // 当frame的宽或高为0的时候，设置bounds的size为改size
    private static let size = CGSize(width: 55, height: 20)
    
    // 定时器
    private var link: CADisplayLink!
    
    // 统计被调用的次数
    private var count: Int
    
    // 上一次被调用的时间戳
    private var lastTime: TimeInterval
    
    // FPS的字体
    private let fpsFont: UIFont
    
    // 间距的字体
    private let subFont: UIFont
    
    override init(frame: CGRect) {
        fpsFont = UIFont.systemFont(ofSize: 14.0)
        subFont = UIFont.systemFont(ofSize: 14.0)
        count = 0
        lastTime = 0
        
        var frame = frame
        if (frame.size.width == 0 || frame.size.height == 0) {
            frame.size = FPSLabel.size
        }
        super.init(frame: frame)
        
        layer.cornerRadius = 5.0
        clipsToBounds = true
        textAlignment = .center
        isUserInteractionEnabled = false
        backgroundColor = UIColor(white: 0.00, alpha: 0.70)
        link = CADisplayLink(target: WeakProxy(self), selector: #selector(tick))
        link.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        link.invalidate()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return FPSLabel.size
    }
    
    /// 定是调用统计打点次数，除以时间得出FPS
    ///
    /// - parameter link: 定时器
    func tick(link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        
        count += 1
        let delta = link.timestamp - lastTime
        if delta < 1 {
            return
        }
        lastTime = link.timestamp
        
        let fps = Double(count) / delta
        count = 0
        
        let progress = CGFloat(fps / 60.0)
        let color = UIColor(hue: 0.27 * (progress - 0.2),
                            saturation: 1,
                            brightness: 0.9,
                            alpha: 1)
        
        let text = NSMutableAttributedString(string: String(format: "%d FPS", Int(round(fps))))
        text.addAttribute(NSForegroundColorAttributeName,
                          value: color,
                          range: NSRange(location: 0, length: text.length - 3))
        text.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.white,
                          range: NSRange(location: text.length - 3, length: 3))
        text.addAttribute(NSFontAttributeName,
                          value: fpsFont,
                          range: NSRange(location: 0, length: text.length))
        text.addAttribute(NSFontAttributeName,
                          value: subFont,
                          range: NSRange(location: text.length - 4, length: 1))
        
        attributedText = text
    }
}
