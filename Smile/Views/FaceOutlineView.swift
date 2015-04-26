//
//  FaceOutlineView.swift
//  Smile
//
//  Created by Sihao Lu on 4/24/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography

@IBDesignable class FaceOutlineView: UIView {
    
    @IBInspectable var lineWidth: CGFloat = 4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor(white: 1, alpha: 0.8) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    lazy var mouthView: FaceMouthView = {
        let view = FaceMouthView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextSetLineJoin(context, kCGLineJoinRound)
        let leftPath = CGPathCreateMutable()
        CGPathMoveToPoint(leftPath, nil, bounds.width * 0.3, bounds.height * 0.15)
        CGPathAddCurveToPoint(leftPath, nil, bounds.width * 0.15, bounds.height * 0.2, bounds.width * 0.1, bounds.height * 0.35, bounds.width * 0.1, bounds.height * 0.5)
        CGPathAddCurveToPoint(leftPath, nil, bounds.width * 0.1, bounds.height * 0.65, bounds.width * 0.15, bounds.height * 0.8, bounds.width * 0.3, bounds.height * (1 - 0.15))
        CGContextAddPath(context, leftPath)
        let rightPath = CGPathCreateMutable()
        CGPathMoveToPoint(rightPath, nil, bounds.width * 0.7, bounds.height * 0.15)
        CGPathAddCurveToPoint(rightPath, nil, bounds.width * 0.85, bounds.height * 0.2, bounds.width * 0.9, bounds.height * 0.35, bounds.width * 0.9, bounds.height * 0.5)
        CGPathAddCurveToPoint(rightPath, nil, bounds.width * 0.9, bounds.height * 0.65, bounds.width * 0.85, bounds.height * 0.8, bounds.width * 0.7, bounds.height * (1 - 0.15))
        CGContextAddPath(context, rightPath)
        CGContextStrokePath(context)
    }
    
    override func prepareForInterfaceBuilder() {
        backgroundColor = UIColor.clearColor()
    }
    
    func fadeIn(duration: NSTimeInterval = 0.75) {
        alpha = 0
        transform = CGAffineTransformMakeScale(2, 2)
        self.mouthView.alpha = 0
        UIView.animateWithDuration(duration * 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            self.alpha = 1
        }) { (_) -> Void in
            UIView.animateWithDuration(duration * 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                self.mouthView.alpha = 1
            }, completion: nil)
        }
    }
    
    func faceRect() -> CGRect {
        let faceSize = CGSizeMake(bounds.width * 0.78, bounds.height * 0.5)
        return CGRect(origin: CGPointMake(bounds.width * 0.0, bounds.height * 0.3), size: faceSize)
    }
    
    func faceRectSuggestedError() -> CGRect {
        return CGRectMake(60, 100, 80, 130)
    }
    
    // MARK: - Private Methods
    private func configureView() {
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
        
        addSubview(mouthView)
        layout(mouthView) { v in
            v.width == 170
            v.height == v.width * 0.55
            v.centerX == v.superview!.centerX
            v.centerY == v.superview!.centerY * 1.4
        }
    }

}
