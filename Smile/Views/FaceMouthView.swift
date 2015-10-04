//
//  FaceMouthView.swift
//  Smile
//
//  Created by Sihao Lu on 4/24/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit

class FaceMouthViewLayer: CAShapeLayer {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if event == "progress" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            return animation
        }
        return super.actionForKey(event)
    }
    
}

@IBDesignable class FaceMouthView: UIView {
    
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
    
    @IBInspectable var progress: CGFloat = 1 {
        didSet {
            self.mouthLayer.strokeStart = progress
            self.mouthLayer.strokeEnd = 1
        }
    }
    
    var mouthOutline: CGPath {
        let width: CGFloat = self.bounds.width
        let height: CGFloat = self.bounds.height
        let path = CGPathCreateMutable()
        let x = (width * width / (4 * height) - height) / 2
        let halfAngle = atan(width / 2 / x)
        let centerAngle = CGFloat(M_PI) * 3 / 2
        let startAngle = centerAngle - halfAngle
        let endAngle = centerAngle + halfAngle
        let radius = sqrt(pow(width / 2, 2) + pow(x, 2))
        CGPathAddArc(path, nil, width / 2, -x + self.lineWidth / 2, radius - self.lineWidth, startAngle, endAngle, false)
        CGPathCloseSubpath(path)
        return path
    }
    
    lazy var mouthLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinRound
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mouthLayer.frame = bounds
    }
    
    override func prepareForInterfaceBuilder() {
        backgroundColor = UIColor.clearColor()
        layer.addSublayer(mouthLayer)
    }
    
    func animate(duration: NSTimeInterval = 1) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.beginTime = CACurrentMediaTime()
        animation.fromValue = CGFloat(1)
        animation.toValue = CGFloat(0)
        animation.duration = duration / 2
        animation.autoreverses = true
        animation.repeatCount = 1
        mouthLayer.addAnimation(animation, forKey: "animation")
    }
    
    // MARK: - Private Methods
    private func configureView() {
        backgroundColor = UIColor.clearColor()
        layer.addSublayer(mouthLayer)
    }
    
    override func drawRect(rect: CGRect) {
        mouthLayer.strokeColor = self.lineColor.CGColor
        mouthLayer.fillColor = UIColor.clearColor().CGColor
        mouthLayer.lineWidth = lineWidth
        mouthLayer.path = mouthOutline
        mouthLayer.frame = bounds
    }


}
