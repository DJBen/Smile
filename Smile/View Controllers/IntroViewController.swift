//
//  IntroViewController.swift
//  Smile
//
//  Created by Sihao Lu on 4/22/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography
import AVFoundation

private let PhotoCaptureViewControllerSegueIdentifier: String = "TakePhotoSegue"

class IntroViewController: UIViewController, MockAlertViewDelegate {
    
    lazy var smileView: SmileIconView = {
        let view =  SmileIconView()
        view.tintColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var welcomeTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.freightSansFontWithStyle(.Book, size: 40)
        label.text = "Welcome to Smile"
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .ByTruncatingTail
        label.numberOfLines = 1
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.alpha = 0
        return label
    }()
    
    lazy var subtitleTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.freightSansFontWithStyle(.Light, size: 32)
        label.text = "Your Stroke Detector"
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .ByTruncatingTail
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.alpha = 0
        return label
    }()
    
    lazy var darkenGradientView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "blue_gradient_darken")
        view.alpha = 0
        return view
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var animateButton: UIButton = {
        let button = UIButton.buttonWithType(.Custom) as! UIButton
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: "animateSmile:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var gradientBackgroundView: UIImageView = {
        let view = UIImageView(frame: CGRectMake(0, 0, 200, 200))
        view.userInteractionEnabled = true
        view.image = UIImage(named: "blue_gradient")
        view.addSubview(self.darkenGradientView)
        view.addSubview(self.smileView)
        view.addSubview(self.animateButton)
        view.addSubview(self.welcomeTextLabel)
        view.addSubview(self.subtitleTextLabel)
        view.addSubview(self.separatorView)
        view.addSubview(self.textView)
        view.addSubview(self.mockAlertView)
        constrain(self.darkenGradientView) { v in
            v.edges == v.superview!.edges
        }
        constrain(self.smileView, self.separatorView, self.animateButton) { s, v, a in
            v.height == 0.5
            v.left == v.superview!.left + 20
            v.right == v.superview!.right - 20
            self.separatorTopConstraint = (v.top == s.bottom + UIScreen.mainScreen().bounds.height)
            
            a.edges == s.edges
        }
        constrain(self.textView, self.separatorView, self.mockAlertView) { t, s, c in
            t.left == s.left
            t.right == s.right
            self.textViewVerticalConstraint = (t.top == s.bottom + 20)
            
            c.top == t.bottom + 16
            c.left == c.superview!.left + 30
            c.right == c.superview!.right - 30
        }
        layout(self.smileView, self.welcomeTextLabel, self.subtitleTextLabel) { s, w, sub in
            s.height == s.width
            s.centerX == s.superview!.centerX
            self.smileIconVerticalConstraint = (s.centerY == s.superview!.centerY)
            self.smileHeightConstraint = (s.height == 80)
            
            w.left == w.superview!.left + 20
            w.right == w.superview!.right - 20
            w.bottom == s.top - 20
            
            sub.left == sub.superview!.left + 20
            sub.right == sub.superview!.right - 20
            sub.top == s.bottom + 20
        }
        return view
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.freightSansFontWithStyle(.Light, size: 18)
        textView.backgroundColor = UIColor.clearColor()
        textView.textColor = UIColor.whiteColor()
        textView.text = "The technology this app uses is a part of my mobile diagnosis project in Johns Hopkins University. It offers a quick method to check whether you have stroke by analyzing your smile. Please allow the app to use the front facing camera to capture your face in order to diagnose."
        textView.editable = false
        textView.scrollEnabled = false
        return textView
    }()
    
    let mockAlertView: MockAlertView = {
        let view = MockAlertView(frame: CGRectMake(0, 0, 200, 200))
        view.setTitle("Let Smile Access Your Camera?", subtitle: "Smile need to access your camera in order to diagnose.", leftButtonTitle: "Don't Allow", rightButtonTitle: "OK")
        return view
    }()
    
    private(set) var presentedCameraPermissionRequest: Bool = false
    
    private var separatorTopConstraint: NSLayoutConstraint!
    private var smileIconVerticalConstraint: NSLayoutConstraint!
    private var smileHeightConstraint: NSLayoutConstraint!
    private var textViewVerticalConstraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showWelcome()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if self.cameraAuthorized() {
                self.handleGrantedAccess()
            } else {
                self.presentCameraPermissionRequest { _ in
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                        Int64(2 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.mockAlertView.highlightRightButton()
                    }
                }
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Events
    func animateSmile(sender: UIButton) {
        smileView.shakeMouth()
    }
    
    // MARK: - Private Methods
    
    private func showWelcome(animated: Bool = true, duration: NSTimeInterval = 0.8) {
        if !animated {
            welcomeTextLabel.alpha = 1
            subtitleTextLabel.alpha = 1
            return
        }
        welcomeTextLabel.alpha = 0
        subtitleTextLabel.alpha = 0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.welcomeTextLabel.alpha = 1
            self.subtitleTextLabel.alpha = 1
        }, completion: nil)
    }
    
    private func presentCameraPermissionRequest(completion: ((complete: Bool) -> Void)? = nil) {
        if presentedCameraPermissionRequest {
            return
        }
        presentedCameraPermissionRequest = true
        self.separatorTopConstraint.constant = 20
        self.smileHeightConstraint.constant = 50
        self.gradientBackgroundView.removeConstraint(self.smileIconVerticalConstraint)
        constrain(self.smileView) { s in
            self.smileIconVerticalConstraint = (s.top == s.superview!.top + 36)
        }
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.darkenGradientView.alpha = 1
            self.welcomeTextLabel.alpha = 0
            self.subtitleTextLabel.alpha = 0
            self.gradientBackgroundView.layoutIfNeeded()
        }) { (complete) -> Void in
            self.smileView.shakeMouth(duration: 1.5)
            completion?(complete: complete)
        }
    }
    
    private func configureViews() {
        mockAlertView.delegate = self
        view.addSubview(gradientBackgroundView)
        layout(gradientBackgroundView) { v in
            v.top == v.superview!.top
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.bottom == v.superview!.bottom
        }
    }
    
    private func authorizeCamera() {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if granted {
                    self.handleGrantedAccess()
                } else {
                    self.handleDeniedAccess()
                }
            })
        case .Denied:
            handleDeniedAccess()
        case .Restricted:
            handleRestrictedAccess()
        case .Authorized:
            handleGrantedAccess()
        }
    }
    
    private func cameraAuthorized() -> Bool {
        return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized
    }
    
    private func handleDeniedAccess() {
        let alert = UIAlertController(title: "Cannot Access Camera", message: "You have denied this app from accessing the camera. Please go to Settings > Privacy > Camera and turn on \"Smile\".", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func handleRestrictedAccess() {
        let alert = UIAlertController(title: "Camera Restricted", message: "Your camera is restricted. Please turn off any Parental Controls or Restrictions in Settings.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func handleGrantedAccess() {
        performSegueWithIdentifier(PhotoCaptureViewControllerSegueIdentifier, sender: self)
    }

    // MARK: - Button Delegate
    
    func alertRightButtonTapped(sender: UIButton) {
        authorizeCamera()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == PhotoCaptureViewControllerSegueIdentifier {
            let navVC = segue.destinationViewController as! UINavigationController
            navVC.transitioningDelegate = TransitionManager.sharedManager
        }
    }
}

