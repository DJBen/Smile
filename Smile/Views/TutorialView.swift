//
//  TutorialView.swift
//  Smile
//
//  Created by Sihao Lu on 4/26/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography

private let TutorialText: String = "To quickly detect stroke, align your face with the outline and smile out your teeth. Three photos will be taken automatically. You can also choose a custom photo from your gallery by tapping the icon on the top right corner. A guidance text will appear on the bottom of the screen to further instruct you."

private let BottomTutorialText: String = "Adjust the camera focus by tapping on any area of the screen. Tap anywhere to dismiss this instruction."

@objc protocol TutorialViewDelegate {
    optional func dismissTutorial(tutorial: TutorialView)
}

class TutorialView: UIView {
    lazy var blurEffect = UIBlurEffect(style: .Dark)
    
    lazy var blurView: UIVisualEffectView = {
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: self.blurEffect)
        blurView.frame = CGRectMake(0, 0, 100, 100)
        return blurView
    }()
    
    lazy var upperVibrantView: UIVisualEffectView = {
        let vibrantView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: self.blurEffect))
        vibrantView.frame = CGRectMake(0, 0, 100, 100)
        return vibrantView
    }()
    
    lazy var lowerVibrantView: UIVisualEffectView = {
        let vibrantView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: self.blurEffect))
        vibrantView.frame = CGRectMake(0, 0, 100, 100)
        return vibrantView
    }()

    lazy var tutorialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.freightSansFontWithStyle(.Light, size: 19)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.text = TutorialText
        return label
    }()
    
    lazy var secondTutorialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.freightSansFontWithStyle(.Light, size: 19)
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.text = BottomTutorialText
        return label
    }()
    
    lazy var focusRingView: CameraFocusIndicatorView = {
        let view = CameraFocusIndicatorView()
        return view
    }()
    
    lazy var smileView: SmileIconView = {
        let view = SmileIconView()
        view.tintColor = UIColor.whiteColor()
        return view
    }()
    
    var delegate: TutorialViewDelegate?
    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, 1000, 1000))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func dismissView(sender: UIButton) {
        delegate?.dismissTutorial?(self)
    }
    
    // MARK: - Private Methods
    private func configureView() {
        userInteractionEnabled = true
        let responseButton: UIButton = UIButton.buttonWithType(.Custom) as! UIButton
        responseButton.backgroundColor = UIColor.clearColor()
        responseButton.addTarget(self, action: "dismissView:", forControlEvents: .TouchUpInside)
        
        addSubview(blurView)
        layout(blurView) { v in
            v.edges == v.superview!.edges
        }
        
        addSubview(responseButton)
        layout(responseButton) { v in
            v.edges == v.superview!.edges
        }
        
        blurView.contentView.addSubview(upperVibrantView)
        blurView.contentView.addSubview(smileView)
        blurView.contentView.addSubview(focusRingView)
        blurView.contentView.addSubview(lowerVibrantView)
        
        constrain(smileView, upperVibrantView, focusRingView) { s, uv, r in
            s.height == s.width
            s.height == 40
            s.top == s.superview!.top + 75
            s.centerX == s.superview!.centerX
            
            uv.top == s.bottom + 20
            uv.leftMargin == uv.superview!.leftMargin + 16
            uv.rightMargin == uv.superview!.rightMargin - 16
            
            r.top == uv.bottom + 35
            r.width == r.height
            r.width == 44
            r.centerX == r.superview!.centerX
        }
        
        layout(upperVibrantView, focusRingView, lowerVibrantView) { uv, r, bv in
            bv.top == r.bottom + 35
            bv.leftMargin == uv.leftMargin
            bv.rightMargin == uv.rightMargin
        }
        
        upperVibrantView.contentView.addSubview(tutorialLabel)
        layout(tutorialLabel) { v in
            v.edges == v.superview!.edges
        }
        
        lowerVibrantView.contentView.addSubview(secondTutorialLabel)
        layout(secondTutorialLabel) { v in
            v.edges == v.superview!.edges
        }

    }
}
