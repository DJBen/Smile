//
//  MockAlertView.swift
//  Smile
//
//  Created by Sihao Lu on 4/22/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography

@objc protocol MockAlertViewDelegate {
    optional func alertLeftButtonTapped(sender: UIButton)
    optional func alertRightButtonTapped(sender: UIButton)
}

class MockAlertView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
        label.textAlignment = .Center
        label.numberOfLines = 2
        label.lineBreakMode = .ByTruncatingTail
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.textAlignment = .Center
        label.numberOfLines = 2
        label.lineBreakMode = .ByTruncatingTail
        return label
    }()
    
    lazy var horizontalSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.grayColor()
        return view
    }()
    
    lazy var verticalSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.grayColor()
        return view
    }()
    
    lazy var leftButton: UIButton = {
        let button = UIButton(type: .System)
        button.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 19)
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 8
        button.addTarget(self, action: "leftButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton(type: .System)
        button.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 8
        button.addTarget(self, action: "rightButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    var delegate: MockAlertViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    // MARK: - Public Methods
    
    func setTitle(title: String, subtitle: String, leftButtonTitle: String, rightButtonTitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        leftButton.setTitle(leftButtonTitle, forState: .Normal)
        rightButton.setTitle(rightButtonTitle, forState: .Normal)
    }
    
    func highlightRightButton() {
        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
            self.rightButton.backgroundColor = UIColor.whiteColor()
        }, completion: nil)
    }
    
    func unhighlightRightButton() {
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.backgroundColor = UIColor(white: 1, alpha: 0.8)
            self.rightButton.backgroundColor = UIColor.clearColor()
        }, completion: nil)
    }
    
    // MARK: - Button Events
    func leftButtonTapped(sender: UIButton) {
        delegate?.alertLeftButtonTapped?(sender)
    }
    
    func rightButtonTapped(sender: UIButton) {
        delegate?.alertRightButtonTapped?(sender)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        layer.cornerRadius = 8
        userInteractionEnabled = true
        backgroundColor = UIColor(white: 1, alpha: 0.8)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(horizontalSeparator)
        addSubview(verticalSeparator)
        addSubview(leftButton)
        addSubview(rightButton)
        constrain(titleLabel, subtitleLabel, horizontalSeparator) { t, s, h in
            t.top == t.superview!.top + 20
            t.left == t.superview!.left + 20
            t.right == t.superview!.right - 20
            t.bottom == s.top - 14 ~ 1000
            
            s.left == t.left
            s.right == t.right
            s.bottom == h.top - 20 ~ 1000
            
            h.height == 0.5 ~ 1000
            h.left == h.superview!.left
            h.right == h.superview!.right
            h.bottom == h.superview!.bottom - 48 ~ 1000
        }
        constrain(horizontalSeparator, verticalSeparator, leftButton) { h, v, lb in
            v.width == 0.5
            v.top == h.bottom
            v.bottom == v.superview!.bottom
            v.centerX == v.superview!.centerX
        
            lb.top == h.bottom
            lb.left == lb.superview!.left
            lb.right == v.left
            lb.bottom == lb.superview!.bottom
        }
        constrain(leftButton, verticalSeparator, rightButton) { lb, v, rb in
            rb.top == lb.top
            rb.left == v.right
            rb.right == rb.superview!.right
            rb.bottom == lb.bottom
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
