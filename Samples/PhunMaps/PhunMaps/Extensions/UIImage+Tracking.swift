//
//  UIImage+Tracking.swift
//  Mapping-Sample
//
//  Created on 9/21/17.
//  Copyright © 2017 Phunware. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func emptyTrackingImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 26, height: 26)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 13.53, y: 24))
        bezierPath.addLine(to: CGPoint(x: 13.44, y: 10.62))
        bezierPath.addLine(to: CGPoint(x: 0, y: 10.71))
        bezierPath.addLine(to: CGPoint(x: 24, y: 0))
        bezierPath.addLine(to: CGPoint(x: 13.53, y: 24))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 14.31, y: 9.74))
        bezierPath.addLine(to: CGPoint(x: 14.38, y: 19.85))
        bezierPath.addLine(to: CGPoint(x: 22.29, y: 1.7))
        bezierPath.addLine(to: CGPoint(x: 4.16, y: 9.81))
        bezierPath.addLine(to: CGPoint(x: 14.31, y: 9.74))
        bezierPath.close()
        bezierPath.miterLimit = 4
        
        color.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            return image
        }
        return UIImage()
    }
    
    class func filledTrackingImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 26, height: 26)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 12.4, y: 22))
        bezierPath.addLine(to: CGPoint(x: 12.33, y: 9.74))
        bezierPath.addLine(to: CGPoint(x: 0, y: 9.81))
        bezierPath.addLine(to: CGPoint(x: 22, y: 0))
        bezierPath.addLine(to: CGPoint(x: 12.4, y: 22))
        bezierPath.close()
        bezierPath.miterLimit = 4
        
        color.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            return image
        }
        return UIImage()
    }
    
    class func trackWithHeadingImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 26, height: 26)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 6.98, y: 0))
        bezierPath.addLine(to: CGPoint(x: 8, y: 0))
        bezierPath.addLine(to: CGPoint(x: 8, y: 6.01))
        bezierPath.addLine(to: CGPoint(x: 6.98, y: 6.01))
        bezierPath.addLine(to: CGPoint(x: 6.98, y: 0))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 7.44, y: 19.01))
        bezierPath.addLine(to: CGPoint(x: 0, y: 26))
        bezierPath.addLine(to: CGPoint(x: 7.39, y: 8.01))
        bezierPath.addLine(to: CGPoint(x: 15, y: 25.91))
        bezierPath.addLine(to: CGPoint(x: 7.44, y: 19.01))
        bezierPath.close()
        bezierPath.miterLimit = 4
        
        color.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            return image
        }
        return UIImage()
    }
}
