//
//  SmileIconView.swift
//  Smile
//
//  Created by Sihao Lu on 4/22/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography

class SmileIconView: UIView {
    private static var SmileNoMouthImage: UIImage = {
        return UIImage(named: "smile_icon_no_mouth")!
    }()
    
    private static var SmileMouthOnlyImage: UIImage = {
        return UIImage(named: "smile_icon_mouth_only")!
    }()
    
    lazy var faceImageView: UIImageView = {
        let imageView = UIImageView(image: SmileIconView.SmileNoMouthImage)
        return imageView
    }()

    lazy var mouthImageView: UIImageView = {
        let imageView = UIImageView(image: SmileIconView.SmileMouthOnlyImage)
        return imageView
    }()
    
    // MARK: - Runloop
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    // MARK: - Public Methods
    
    func shakeMouth(duration: NSTimeInterval = 0.8) {
        var transform = CGAffineTransformIdentity
        mouthImageView.transform = transform
        UIView.animateWithDuration(duration * 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: { () -> Void in
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI / 6))
            self.mouthImageView.transform = transform
        }) { (completion) -> Void in
            UIView.animateWithDuration(duration * 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: nil, animations: { () -> Void in
                transform = CGAffineTransformRotate(transform, CGFloat(-M_PI / 3))
                self.mouthImageView.transform = transform
            }) { (completion) -> Void in
                UIView.animateWithDuration(duration * 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: -0.5, options: nil, animations: { () -> Void in
                    transform = CGAffineTransformRotate(transform, CGFloat(M_PI / 6))
                    self.mouthImageView.transform = transform
                }) { (completion) -> Void in
                }
            }
        }
    }
    
    func appear(animated: Bool = true, duration: NSTimeInterval = 0.5) {
        if !animated {
            self.transform = CGAffineTransformMakeScale(1, 1)
            return
        }
        self.transform = CGAffineTransformMakeScale(0.001, 0.001)
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: nil)
    }
    
    func disappear(animated: Bool = true, duration: NSTimeInterval = 0.5) {
        if !animated {
            self.transform = CGAffineTransformMakeScale(0, 0)
            return
        }
        self.transform = CGAffineTransformMakeScale(1, 1)
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.001, 0.001)
        }, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        addSubview(faceImageView)
        addSubview(mouthImageView)
        layout(faceImageView, mouthImageView) { f, m in
            f.edges == f.superview!.edges
            m.edges == m.superview!.edges
        }
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
