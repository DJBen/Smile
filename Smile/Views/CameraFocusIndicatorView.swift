//
//  CameraFocusIndicatorView.swift
//  Smile
//
//  Created by Sihao Lu on 4/23/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography

class CameraFocusIndicatorView: UIView {
    
    lazy var outerRing: RingView = {
        let view = RingView()
        view.backgroundColor = UIColor.clearColor()
        view.ringWidth = 1
        view.ringColor = UIColor(white: 1, alpha: 0.5)
        view.alpha = 0
        return view
    }()
    
    lazy var innerRing: RingView = {
        let view = RingView()
        view.backgroundColor = UIColor.clearColor()
        view.ringWidth = 4
        view.ringColor = UIColor.whiteColor()
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
    
    // MARK: - Public Methods
    
    func animateFocus(duration: NSTimeInterval = 1.2, outerRingSizeRatio: CGFloat = 3, completion: (Bool -> Void)? = nil) {
        var transform = CGAffineTransformMakeScale(outerRingSizeRatio, outerRingSizeRatio)
        outerRing.transform = transform
        self.transform = CGAffineTransformIdentity
        let normalizedDurations: [NSTimeInterval] = CameraFocusIndicatorView.normalizeDurations([1, 8, 3, 2, 4], totalDuration: duration)
        self.alpha = 0
        UIView.animateWithDuration(normalizedDurations[0], delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.alpha = 1
        }) { (_) -> Void in
            self.outerRing.alpha = 1
            UIView.animateWithDuration(normalizedDurations[1], delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                // Constract outer ring
                transform = CGAffineTransformIdentity
                self.outerRing.transform = transform
            }, completion: { (_) -> Void in
                UIView.animateWithDuration(normalizedDurations[2], delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                    self.outerRing.alpha = 0
                }, completion: { (_) -> Void in
                    UIView.animateWithDuration(normalizedDurations[4], delay: normalizedDurations[3], usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                        self.transform = CGAffineTransformMakeScale(1.2, 1.2)
                        self.alpha = 0
                    }, completion: completion)
                })
            })
        }
    }
    
    func loopAnimateRing(duration: NSTimeInterval = 2.5, outerRingSizeRatio: CGFloat = 3) {
        self.alpha = 0
        self.outerRing.alpha = 1
        self.outerRing.transform = CGAffineTransformMakeScale(outerRingSizeRatio, outerRingSizeRatio)
        let normalizedDurations: [NSTimeInterval] = CameraFocusIndicatorView.normalizeDurations([1, 3], totalDuration: duration)
        UIView.animateWithDuration(normalizedDurations[0], delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: {
            self.alpha = 1
        }) { (_) -> Void in
            UIView.animateWithDuration(normalizedDurations[1], delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.Repeat, animations: { () -> Void in
                self.outerRing.transform = CGAffineTransformIdentity
            }, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    private class func normalizeDurations(durations: [NSTimeInterval], totalDuration: NSTimeInterval) -> [NSTimeInterval] {
        let sum = durations.reduce(0, combine: +)
        return durations.map { $0 / sum * totalDuration }
    }
    
    private func configureView() {
        clipsToBounds = false
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
        alpha = 0
        addSubview(outerRing)
        addSubview(innerRing)
        layout(innerRing, outerRing) { i, o in
            o.edges == inset(o.superview!.edges, -1)
            i.edges == i.superview!.edges
        }
    }
}

class RingView: UIView {
    var ringColor: UIColor = UIColor.whiteColor()
    var ringWidth: CGFloat = 5

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, ringColor.CGColor)
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextSetLineWidth(context, ringWidth)
        CGContextStrokeEllipseInRect(context, CGRectInset(bounds, ringWidth / 2, ringWidth / 2))
    }
}
