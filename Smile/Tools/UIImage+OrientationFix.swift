//
//  UIImage+OrientationFix.swift
//
//  Created by Sihao Lu on 4/22/15.
//  Copyright (c) 2015 DJ.Ben. All rights reserved.
//

import UIKit

extension UIImage {
    func imageByFixingOrientation() -> UIImage {
        if imageOrientation == .Up {
            return self
        }
        var transform = CGAffineTransformIdentity
        switch imageOrientation {
        case .Down:
            fallthrough
        case .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left:
            fallthrough
        case .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right:
            fallthrough
        case .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        case .Up:
            fallthrough
        default:
            break
        }
        switch imageOrientation {
        case .UpMirrored:
            fallthrough
        case .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored:
            fallthrough
        case .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue)
        CGContextConcatCTM(context, transform)
        switch imageOrientation {
        case .Left:
            fallthrough
        case .LeftMirrored:
            fallthrough
        case .Right:
            fallthrough
        case .RightMirrored:
            CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage)
        default:
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage)
        }
        let cgImg = CGBitmapContextCreateImage(context)!
        return UIImage(CGImage: cgImg)
    }
}
