//
//  CGUtilities.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/12.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

private let scale = C.UI.screenScale

extension CGFloat {
    var toPixel: CGFloat {
        return self * scale
    }
    
    static func from(pixel: CGFloat) -> CGFloat {
        return pixel / scale
    }
    
    var pixelFloor: CGFloat {
        return floor(self * scale) / scale
    }
    
    var pixelRound: CGFloat {
        return Darwin.round(self * scale) / scale
    }
    
    var pixelCeil: CGFloat {
        return ceil(self * scale) / scale
    }
    
    var pixelHalf: CGFloat {
        return (floor(self * scale) + 0.5) / scale
    }
}

extension CGPoint {
    var pixelFloor: CGPoint {
        return CGPoint(x: floor(self.x * scale) / scale, y: floor(self.y * scale) / scale)
    }
    
    var pixelRound: CGPoint {
        return CGPoint(x: round(self.x * scale) / scale, y: round(self.y * scale) / scale)
    }
    
    var pixelCeil: CGPoint {
        return CGPoint(x: ceil(self.x * scale) / scale, y: ceil(self.y * scale) / scale)
    }
    
    var pixelHalf: CGPoint {
        return CGPoint(x: (floor(self.x * scale) + 0.5) / scale, y: (floor(self.y * scale) + 0.5) / scale)
    }
}

extension CGSize {
    var pixelFloor: CGSize {
        return CGSize(width: floor(self.width * scale) / scale, height: floor(self.height * scale) / scale)
    }
    
    var pixelRound: CGSize {
        return CGSize(width: round(self.width * scale) / scale, height: round(self.height * scale) / scale)
    }
    
    var pixelCeil: CGSize {
        return CGSize(width: ceil(self.width * scale) / scale, height: ceil(self.height * scale) / scale)
    }
    
    var pixelHalf: CGSize {
        return CGSize(width: (floor(self.width * scale) + 0.5) / scale, height: (floor(self.height * scale) + 0.5) / scale)
    }
}

extension CGRect {
    var pixelFloor: CGRect {
        let origin = self.origin.pixelFloor
        let corner = CGPoint(x: origin.x + size.width, y: origin.y + size.height).pixelFloor
        var rect = CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
        if rect.size.width < 0 {
            rect.size.width = 0
        } else if rect.size.height < 0 {
            rect.size.height = 0
        }
        
        return rect
    }
    
    var pixelRound: CGRect {
        let origin = self.origin.pixelRound
        let corner = CGPoint(x: origin.x + size.width, y: origin.y + size.height).pixelRound
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }
    
    var pixelCeil: CGRect {
        let origin = self.origin.pixelCeil
        let corner = CGPoint(x: origin.x + size.width, y: origin.y + size.height).pixelCeil
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }
    
    var pixelHalf: CGRect {
        let origin = self.origin.pixelHalf
        let corner = CGPoint(x: origin.x + size.width, y: origin.y + size.height).pixelHalf
        return CGRect(x: origin.x, y: origin.y, width: corner.x - origin.x, height: corner.y - origin.y)
    }
}

extension UIEdgeInsets {
    var pixelFloor: UIEdgeInsets {
        var insets = self
        insets.top = insets.top.pixelFloor
        insets.left = insets.left.pixelFloor
        insets.bottom = insets.bottom.pixelFloor
        insets.right = insets.right.pixelFloor
        return insets
    }
    
    var pixelCeil: UIEdgeInsets {
        var insets = self
        insets.top = insets.top.pixelCeil
        insets.left = insets.left.pixelCeil
        insets.bottom = insets.bottom.pixelCeil
        insets.right = insets.right.pixelCeil
        return insets
    }
}
