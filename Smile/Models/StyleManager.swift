//
//  StyleManager.swift
//  Smile
//
//  Created by Sihao Lu on 1/13/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit

let style = StyleManager.sharedManager

class StyleManager: NSObject {
    class var sharedManager : StyleManager {
        struct Static {
            static let instance : StyleManager = StyleManager()
        }
        return Static.instance
    }
    
    enum SmileColor: CGFloat {
        case Blue = 200
        case Green = 130
        case Red = 5
        case Orange = 17
        case LightOrange = 31
        case Purple = 320
    }
    
}

private var smileImageCache: [CGFloat: UIImage] = [CGFloat: UIImage]()

extension UIImage {
    class func imageFromSmileColor(color: StyleManager.SmileColor) -> UIImage {
        if let image = smileImageCache[color.rawValue] {
            return image
        } else {
            UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
            UIColor.SmileColor(color).set()
            let context = UIGraphicsGetCurrentContext()
            CGContextStrokeRect(context, CGRectMake(0, 0, 1, 1))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            smileImageCache[color.rawValue] = image
            return image
        }
    }
}

extension UIColor {
    class func SmileColor(color: StyleManager.SmileColor) -> UIColor {
        return UIColor(hue: color.rawValue / 360.0, saturation: 0.7, brightness: 0.88, alpha: 1)
    }
    
    class func randomSmileColor() -> UIColor {
        return UIColor(hue: CGFloat(arc4random_uniform(360)) / 360.0, saturation: 0.7, brightness: 0.9, alpha: 1)
    }
    
    func lighterColor(factor: CGFloat = 1.3) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: min(255.0, brightness * factor), alpha: alpha)
    }
    
    class func SmileColorWithPercentage(percentage: Double, gradientStart: CGFloat, gradientEnd: CGFloat, reversed: Bool = false) -> UIColor {
        let difference = abs(Double(gradientEnd - gradientStart))
        _ = max(min(1.0, percentage), 0.0)
        let offset = difference * percentage
        let value = reversed ? Double(gradientEnd) - offset : Double(gradientStart) + offset
        return UIColor(hue: CGFloat(value) / 360.0, saturation: 0.7, brightness: 0.9, alpha: 1)
    }
    
    class var facebookColor: UIColor {
        return UIColor(red: 59 / 255.0, green: 89 / 255.0, blue: 152 / 255.0, alpha: 1)
    }
    
    class var twitterColor: UIColor {
        return UIColor(red: 85 / 255.0, green: 172 / 255.0, blue: 238 / 255.0, alpha: 1)
    }
    
    class var mailColor: UIColor {
        return UIColor(red: 135 / 255.0, green: 206 / 255.0, blue: 250 / 255.0, alpha: 1)
    }
}

extension UIFont {
    enum FreightSansFontStyle: String {
        case Book = "FreightSansProBook-Regular"
        case Light = "FreightSansProLight-Regular"
        case Medium = "FreightSansProMedium-Regular"
        case Semibold = "FreightSansProSemibold-Regular"
    }
    
    class func freightSansFontWithStyle(style: FreightSansFontStyle, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size)!
    }
}
