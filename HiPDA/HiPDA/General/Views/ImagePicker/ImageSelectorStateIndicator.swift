//
//  ImageSelectorStateIndicator.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/18.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import CoreGraphics

class ImageSelectorStateIndicator: UIView {
    private let borderColor: UIColor
    private let borderShadowColor: UIColor
    private let selectedBackgroundColor: UIColor
    private let selectedTextColor: UIColor
    private let downloadColor: UIColor
    var selectionNumber: Int {
        didSet {
            isDownloading = false
            downloadProgress = 0.0
            updateSelectionLabel()
            setNeedsDisplay()
        }
    }
    var isDownloading: Bool {
        didSet {
            if isDownloading != oldValue {
                setNeedsDisplay()
            }
        }
    }
    var downloadProgress: Double {
        didSet {
            setNeedsDisplay()
        }
    }
    var isSelected: Bool {
        return selectionNumber > 0
    }
    private let selectionLabel: UILabel
    
    override init(frame: CGRect) {
        borderColor = .white
        borderShadowColor = .darkGray
        selectedBackgroundColor = .white
        selectedTextColor = #colorLiteral(red: 0, green: 0.6862745098, blue: 0.8941176471, alpha: 1)
        downloadColor = #colorLiteral(red: 0.1607843137, green: 1, blue: 0.2156862745, alpha: 1)
        
        selectionLabel = UILabel()
        selectionLabel.backgroundColor = .clear
        selectionLabel.isOpaque = false
        selectionLabel.textAlignment = .center
        selectionLabel.font = UIFont.systemFont(ofSize: 20.0)
        selectionLabel.textColor = selectedTextColor
        
        selectionNumber = -1
        isDownloading = false
        downloadProgress = 0
        
        super.init(frame: frame)
        addSubview(selectionLabel)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionLabel.frame = bounds
    }
    
    func clearState() {
        selectionNumber = -1
        isDownloading = false
        downloadProgress = 0
        selectionLabel.text = ""
        
        setNeedsDisplay()
    }
    
    func updateSelectionLabel() {
        if isDownloading {
            selectionLabel.text = "↓"
        } else if selectionNumber > 0 {
            selectionLabel.text = "\(selectionNumber)"
        } else {
            selectionLabel.text = ""
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateSelectionLabel()
        guard let context = UIGraphicsGetCurrentContext() else { return }
        backgroundColor = .clear
        context.clear(rect)
        
        if !isSelected && !isDownloading {
            return
        }
        
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.55)
        context.fill(rect)
        
        let size = (frame.size.width * 0.45).pixelRound
        let offset = ((frame.size.width - size) / 2.0).pixelRound
        let controlRect = CGRect(x: offset, y: offset, width: size, height: size)
        
        let borderWidth = CGFloat(1.0)
        let borderRectOuterSpace = CGFloat(0.0)
        
        let borderRect = CGRect(x: controlRect.origin.x + borderRectOuterSpace, y: controlRect.origin.y + borderRectOuterSpace, width: controlRect.size.width - borderRectOuterSpace * 2, height: controlRect.size.height - borderRectOuterSpace * 2)
        let r = min(controlRect.size.width, controlRect.size.height) / 2.0 - borderRectOuterSpace
        
        let borderPath = ImageSelectorStateIndicator.borderPath(in: borderRect, radius: r)
        
        context.beginPath()
        context.addPath(borderPath)
        context.setStrokeColor(borderShadowColor.cgColor)
        context.setLineWidth(borderWidth + 0.5)
        context.strokePath()
        
        context.beginPath()
        context.addPath(borderPath)
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(borderWidth)
        
        if isSelected || isDownloading {
            context.setFillColor(selectedBackgroundColor.cgColor)
        } else {
            context.setFillColor(UIColor.clear.cgColor)
        }
        context.drawPath(using: .fillStroke)
        
        if isDownloading {
            let downloadLineWidth = CGFloat(3)
            let downloadRect = CGRect(x: borderRect.origin.x + downloadLineWidth / 2, y: borderRect.origin.y + downloadLineWidth / 2, width: borderRect.size.width - downloadLineWidth, height: borderRect.size.height - downloadLineWidth)
            let downloadPath = ImageSelectorStateIndicator.borderPath(in: downloadRect, radius: r - downloadLineWidth / 2)
            
            context.saveGState()
            context.beginPath()
            context.move(to: CGPoint(x: controlRect.midX, y: controlRect.midY))
            context.addArc(center: CGPoint(x: controlRect.midX, y: controlRect.midY), radius: r + borderWidth / 2, startAngle: .pi * 1.5, endAngle: .pi * CGFloat(1.5 + downloadProgress * 2.0), clockwise: false)
            context.addLine(to: CGPoint(x: controlRect.midX, y: controlRect.midY))
            context.closePath()
            context.clip()
            
            context.beginPath()
            context.addPath(downloadPath)
            context.setStrokeColor(downloadColor.cgColor)
            context.setFillColor(UIColor.clear.cgColor)
            context.setLineWidth(downloadLineWidth + borderWidth)
            
            context.drawPath(using: .fillStroke)
            
            context.restoreGState()
        }
    }
    
    fileprivate static func borderPath(in rect: CGRect, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let x1 = rect.origin.x
        let x2 = rect.origin.x + rect.size.width
        let y1 = rect.origin.y
        let y2 = rect.origin.y + rect.size.height
        
        path.move(to: CGPoint(x: x2, y: y2 - radius))
        path.addArc(center: CGPoint(x: x2 - radius, y: y2 - radius), radius: radius, startAngle: 0.0, endAngle: .pi / 2.0, clockwise: false)
        path.addLine(to: CGPoint(x: x1 + radius, y: y2))
        path.addArc(center: CGPoint(x: x1 + radius, y: y2 - radius), radius: radius, startAngle: .pi / 2.0, endAngle: .pi, clockwise: false)
        path.addLine(to: CGPoint(x: x1, y: y1 + radius))
        path.addArc(center: CGPoint(x: x1 + radius, y: y2 - radius), radius: radius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: false)
        path.addLine(to: CGPoint(x: x2 - radius, y: y1))
        path.addArc(center: CGPoint(x: x2 - radius, y: y2 - radius), radius: radius, startAngle: .pi * 1.5, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: x2, y: y2 - radius))
        path.closeSubpath()
        
        return path
    }
}
