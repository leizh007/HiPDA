//
//  UIImage+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/16.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

extension UIImage {
    /// 取得view的截图
    ///
    /// - parameter view:  待截图的view
    /// - parameter frame: 待截图区域（相较于view）
    ///
    /// - returns: 截图
    @nonobjc
    static func snapshot(of view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    //https://github.com/ibireme/YYWebImage/blob/e8009ae33bb30ac6a1158022fa216a932310c857/YYWebImage/Categories/UIImage%2BYYWebImage.m
    func image(roundCornerRadius radius: CGFloat, corners: UIRectCorner, borderWidth: CGFloat, borderColor: UIColor, borderLineJoin: CGLineJoin) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -rect.size.height)
        
        let minSize = min(size.width, size.height)
        if borderWidth < minSize / 2 {
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: borderWidth, dy: borderWidth), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            path.close()
            
            context.saveGState()
            path.addClip()
            guard let cgImage = self.cgImage else {
                return nil
            }
            context.draw(cgImage, in: rect)
            context.restoreGState()
        }
        
        if borderWidth < minSize / 2 && borderWidth > 0 {
            let strokeInset = (floor(borderWidth * scale) + 0.5) / scale
            let strokeRect = rect.insetBy(dx: strokeInset, dy: strokeInset)
            let strokeRadius = radius > scale / 2 ? radius - scale / 2 : 0
            let path = UIBezierPath(roundedRect: strokeRect, byRoundingCorners: corners, cornerRadii: CGSize(width: strokeRadius, height: strokeRadius))
            path.close()
            
            path.lineWidth = borderWidth
            path.lineJoinStyle = borderLineJoin
            borderColor.setStroke()
            path.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func image(roundCornerRadius radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        return image(roundCornerRadius: radius, corners: .allCorners, borderWidth: borderWidth, borderColor: borderColor, borderLineJoin: .miter)
    }
}
