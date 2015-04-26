//
//  PhotoCaptureViewController.swift
//  Smile
//
//  Created by Sihao Lu on 4/22/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography
import AVFoundation

private let ProcessCapturedImageSegueIdentifier = "ProcessCapturesSegue"
let UnwindFromDiagnosisSegueIdentifier = "backFromDiagnosis"

class PhotoCaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate, CameraPreviewViewDelegate, TutorialViewDelegate {
    
    static let numberOfSnaps: Int = 3
    static let autoCaptureInterval: CMTime = CMTimeMake(3, 2)
    
    enum FaceStatus: Printable {
        case Usable
        case OutOfBound
        case RollNotPass(CGFloat)
        case YawNotPass(CGFloat)
        
        var description: String {
            switch self {
            case .Usable:
                return "FaceStatus<Usable>"
            case .OutOfBound:
                return "FaceStatus<OutOfBound>"
            case .RollNotPass(let roll):
                return "FaceStatus<RollNotPass(\(roll))>"
            case .YawNotPass(let yaw):
                return "FaceStatus<YawNotPass(\(yaw))"
            }
        }
    }
    
    lazy var blurEffect = UIBlurEffect(style: .Dark)
    
    lazy var blurView: UIVisualEffectView = {
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: self.blurEffect)
        blurView.frame = CGRectMake(0, 0, 100, 100)
        return blurView
    }()
    
    lazy var vibrantView: UIVisualEffectView = {
        let vibrantView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: self.blurEffect))
        vibrantView.frame = CGRectMake(0, 0, 100, 100)
        return vibrantView
    }()

    lazy var previewView: CameraPreviewView = {
        let view = CameraPreviewView()
        view.delegate = self
        return view
    }()
    
    lazy var faceOutlineView: FaceOutlineView = {
        let view = FaceOutlineView()
        view.alpha = 0
        return view
    }()
    
    lazy var tutorialView: TutorialView = {
        let view = TutorialView()
        view.delegate = self
        return view
    }()
    
    lazy var guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.freightSansFontWithStyle(.Book, size: 20)
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 2
        label.lineBreakMode = .ByTruncatingTail
        label.minimumScaleFactor = 0.5
        label.textAlignment = .Center
        label.layer.shadowRadius = 5
        label.layer.shadowColor = UIColor.blackColor().CGColor
        label.layer.shadowOpacity = 0.6
        return label
    }()
    
    private var guidanceText: String? {
        get {
            return guideLabel.text
        }
        set {
            guideLabel.text = newValue
        }
    }
    
    var focusIndicator: CameraFocusIndicatorView?
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureVideoDataOutput?
    var metadataOutput: AVCaptureMetadataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer {
        return (previewView.layer as! AVCaptureVideoPreviewLayer)
    }
    
    var faceStatus: FaceStatus = .OutOfBound {
        willSet {
            switch newValue {
            case .Usable:
                guideLabel.font = UIFont.freightSansFontWithStyle(.Medium, size: 24)
            default:
                guideLabel.font = UIFont.freightSansFontWithStyle(.Book, size: 20)
            }

            switch newValue {
            case .Usable:
                faceOutlineView.lineColor = UIColor.SmileColor(.Green).colorWithAlphaComponent(0.8)
                guidanceText = "Smile Out Your Teeth. Steady."
                break
            case .OutOfBound:
                faceOutlineView.lineColor = UIColor(white: 1, alpha: 0.8)
                guidanceText = "Please move your camera so that your face fills the outline."
            case .RollNotPass(let _):
                faceOutlineView.lineColor = UIColor.SmileColor(.Red).colorWithAlphaComponent(0.8)
                guidanceText = "Please keep your head straight."
            case .YawNotPass(let yaw):
                faceOutlineView.lineColor = UIColor.SmileColor(.Red).colorWithAlphaComponent(0.8)
                if yaw > 0 && yaw <= 90 {
                    guidanceText = "Please turn your head slightly to the right."
                } else {
                    guidanceText = "Please turn your head slightly to the left."
                }
            }
        }
    }
    
    var stopCapturing: Bool = false {
        willSet {
            if newValue {
                println("Capture stopped: no longer processing frames")
            } else {
                println("Start capturing: process frames when adequet")
            }
        }
    }
    
    var tutorialShown: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("tutorial") ?? false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "tutorial")
        }
    }
    
    private var queue: dispatch_queue_t!
    private var device: AVCaptureDevice!
    private var interestPoint: CGPoint = CGPointMake(0.5, 0.5)
    private var faceMetadata: [AVMetadataFaceObject]!
    private var lastDetectedTime: CMTime?
    private var initialUsableDetectTime: CMTime? {
        willSet {
            if newValue == nil {
//                println("Initial usable time: RESET")
            } else {
//                println("Initial usable time: \(CMTimeCopyDescription(nil, newValue!))")
            }
        }
    }
    private var capturedImages: [UIImage] = [UIImage]()
    private var blurViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        queue = dispatch_queue_create("SessionQueue", nil)
        enableUserInteractions(false)
        dispatch_async(queue) {
            self.captureSession = AVCaptureSession()
            self.captureSession!.sessionPreset = AVCaptureSessionPresetHigh
            
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
            let frontDevice: [AVCaptureDevice] = devices.filter { $0.position == .Front }
            if frontDevice.isEmpty {
                self.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            } else {
                self.device = frontDevice[0]
            }
            self.setCameraFocusAndExposure()
            
            var error: NSError?
            var input = AVCaptureDeviceInput(device: self.device, error: &error)
            if error == nil && self.captureSession!.canAddInput(input) {
                self.captureSession!.addInput(input)
                self.videoOutput = AVCaptureVideoDataOutput()
                if self.captureSession!.canAddOutput(self.videoOutput) {
                    self.captureSession!.addOutput(self.videoOutput)
                    self.videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
                    self.videoOutput!.alwaysDiscardsLateVideoFrames = true
                    self.videoOutput!.setSampleBufferDelegate(self, queue: self.queue)
                }
                self.metadataOutput = AVCaptureMetadataOutput()
                if self.captureSession!.canAddOutput(self.metadataOutput) {
                    self.captureSession!.addOutput(self.metadataOutput)
                    self.metadataOutput!.metadataObjectTypes = [AVMetadataObjectTypeFace]
                    self.metadataOutput!.setMetadataObjectsDelegate(self, queue: self.queue)
                }
                self.previewView.session = self.captureSession!
                self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                self.captureSession!.startRunning()
                self.enableUserInteractions(true)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.faceStatus = .OutOfBound
        stopCapturing = false
        if !tutorialShown {
            self.showTutorial()
        } else {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.animateViewInitializations()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Events
    func chooseFromGallery(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - AV Capture Delegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if lastDetectedTime != nil {
            let allowedTimeRange = CMTimeRangeMake(lastDetectedTime!, CMTimeMake(8, 10))
            if CMTimeRangeContainsTime(allowedTimeRange, time) == 1 {
            } else {
                // Face not there any more
                self.initialUsableDetectTime = nil
                dispatch_async(dispatch_get_main_queue()) {
                    self.faceStatus = .OutOfBound
                }
            }
        }
        if initialUsableDetectTime != nil {
            let allowedTimeRange = CMTimeRangeMake(self.initialUsableDetectTime!, PhotoCaptureViewController.autoCaptureInterval)
            if CMTimeRangeContainsTime(allowedTimeRange, time) == 1 {
            } else {
                if stopCapturing {
                    return
                }
                if let image = UIImage(fromSampleBuffer: sampleBuffer) {
                    println(">>> Photo captured!!!!")
                    self.capturedImages.append(image.imageByFixingOrientation())
                    self.initialUsableDetectTime = nil
                    dispatch_async(dispatch_get_main_queue()) {
                        self.flash()
                        self.faceOutlineView.mouthView.layer.removeAnimationForKey("animation")
                        if self.capturedImages.count == PhotoCaptureViewController.numberOfSnaps {
                            self.stopCapturing = true
                            self.captureSession?.stopRunning()
                            self.performSegueWithIdentifier(ProcessCapturedImageSegueIdentifier, sender: self)
                        }
                    }
                }
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var transformedMetadata: [AVMetadataFaceObject] = [AVMetadataFaceObject]()
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            if metadataObject.type == AVMetadataObjectTypeFace {
                if let faceObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject) as? AVMetadataFaceObject {
                    transformedMetadata.append(faceObject)
                }
            }
        }
        faceMetadata = transformedMetadata
        if !faceMetadata.isEmpty {
            let face = faceMetadata[0]
            lastDetectedTime = face.time
            dispatch_async(dispatch_get_main_queue()) {
                // Detect roll and yaw
                if face.hasRollAngle && face.rollAngle != 0 {
                    self.faceStatus = .RollNotPass(face.rollAngle)
                } else if face.hasYawAngle && face.yawAngle != 0 {
                    self.faceStatus = .YawNotPass(face.yawAngle)
                } else {
                    let resembles = face.bounds.resemblesRect(CGRectOffset(self.faceOutlineView.faceRect(), self.faceOutlineView.frame.origin.x, self.faceOutlineView.frame.origin.y), withError: self.faceOutlineView.faceRectSuggestedError())
                    if resembles {
                        self.faceStatus = .Usable
                    } else {
                        self.faceStatus = .OutOfBound
                    }
                }
                switch self.faceStatus {
                case .Usable:
                    if self.initialUsableDetectTime == nil {
                        self.initialUsableDetectTime = face.time
                        if self.capturedImages.count < PhotoCaptureViewController.numberOfSnaps {
                            let duration = NSTimeInterval(CMTimeGetSeconds(PhotoCaptureViewController.autoCaptureInterval))
                            self.faceOutlineView.mouthView.animate(duration: duration)
                        }
                    }
                default:
                    self.initialUsableDetectTime = nil
                    self.faceOutlineView.mouthView.layer.removeAnimationForKey("animation")
                }
            }
        }
    }
    
    // MARK: - Camera Preview View Delegate
    func requestCameraFocusChangeToPoint(point: CGPoint, inView pointInView: CGPoint) {
        showFocusIndicatorAtPoint(pointInView)
        dispatch_async(queue) {
            self.setCameraFocusAndExposure(point: point)
        }
    }
    
    // MARK: - Tutorial View Delegate
    func dismissTutorial(tutorial: TutorialView) {
        self.blurViewBottomConstraint.constant = 0
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            tutorial.alpha = 0
            tutorial.transform = CGAffineTransformMakeScale(0.7, 0.7)
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            self.stopCapturing = false
            self.tutorialShown = true
            tutorial.removeFromSuperview()
            self.animateViewInitializations()
        }
    }
    
    // MARK: - Private Methods
    
    private func setCameraFocusAndExposure(point: CGPoint = CGPointMake(0.5, 0.5)) {
        var error: NSError?
        if device.lockForConfiguration(&error) {
            if device.focusPointOfInterestSupported {
                device.focusPointOfInterest = point
            }
            if device.isFocusModeSupported(.ContinuousAutoFocus) {
                device.focusMode = .ContinuousAutoFocus
            }
            if device.exposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
            }
            if device.isExposureModeSupported(.ContinuousAutoExposure) {
                device.exposureMode = .ContinuousAutoExposure
            }
            device.subjectAreaChangeMonitoringEnabled = true
            interestPoint = point
            device.unlockForConfiguration()
        } else {
            println("Failed to set focus and exposure to point \(point): \(error)")
        }
    }
    
    private func configureViews() {
        makeNavigationBarTransparent()
        navigationItem.title = "Smile"
        
//        let galleryButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "gallery_icon"), style: .Plain, target: self, action: "chooseFromGallery:")
//        navigationItem.rightBarButtonItem = galleryButton
        
        view.addSubview(previewView)
        view.addSubview(faceOutlineView)
        view.addSubview(blurView)
        blurView.contentView.addSubview(vibrantView)
        vibrantView.contentView.addSubview(guideLabel)
        
        layout(guideLabel) { g in
            g.bottom == g.superview!.bottom - 10
            g.left == g.superview!.left + 40
            g.right == g.superview!.right - 40
            g.top == g.superview!.top + 10
        }
        
        layout(vibrantView) { v in
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom
            v.left == v.superview!.left
            v.right == v.superview!.right
        }
        
        layout(blurView, previewView, faceOutlineView) { v, p, f in
            v.height == 80
            self.blurViewBottomConstraint = (v.bottom == v.superview!.bottom)
            v.left == v.superview!.left
            v.right == v.superview!.right
            
            p.top == p.superview!.top
            p.left == p.superview!.left
            p.right == p.superview!.right
            p.bottom == p.superview!.bottom
            
            f.top == f.superview!.top
            f.left == f.superview!.left
            f.right == f.superview!.right
            f.bottom == v.top
        }

    }
    
    private func showFocusIndicatorAtPoint(point: CGPoint) {
        focusIndicator?.removeFromSuperview()
        let indicator = CameraFocusIndicatorView()
        focusIndicator = indicator
        view.addSubview(indicator)
        let size = CGSizeMake(48, 48)
        indicator.frame = CGRect(origin: CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2), size: size)
        indicator.animateFocus(completion: { _ in
            indicator.removeFromSuperview()
        })
    }
    
    private func showTutorial(completion: (Bool -> Void)? = nil) {
        if tutorialView.superview != nil {
            return
        }
        stopCapturing = true
        view.addSubview(tutorialView)
        layout(tutorialView, blurView) { t, b in
            t.top == t.superview!.top
            t.left == t.superview!.left
            t.right == t.superview!.right
            t.bottom == b.superview!.bottom
        }
        self.blurViewBottomConstraint.constant = 80
        tutorialView.alpha = 0
        tutorialView.transform = CGAffineTransformMakeScale(0.7, 0.7)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.tutorialView.alpha = 1
            self.tutorialView.transform = CGAffineTransformIdentity
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
            self.tutorialView.focusRingView.loopAnimateRing()
            completion?(complete)
        }
    }
    
    private func animateViewInitializations() {
        self.faceOutlineView.fadeIn()
        self.faceOutlineView.mouthView.animate()
        self.showFocusIndicatorAtPoint(self.view.center)
        self.setCameraFocusAndExposure()
    }
    
    private func flash(duration: NSTimeInterval = 0.3) {
        let flashView = UIView()
        flashView.backgroundColor = UIColor.whiteColor()
        flashView.frame = view.bounds
        view.addSubview(flashView)
        view.bringSubviewToFront(flashView)
        flashView.alpha = 0
        UIView.animateWithDuration(duration / 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: nil, animations: { () -> Void in
            flashView.alpha = 0.9
        }) { (_) -> Void in
            UIView.animateWithDuration(duration / 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                flashView.alpha = 0
            }) { (_) -> Void in
                flashView.removeFromSuperview()
            }
        }
    }
    
    private func enableUserInteractions(enabled: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.previewView.userInteractionEnabled = enabled
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ProcessCapturedImageSegueIdentifier {
            let diagnoseVC = segue.destinationViewController as! DiagnoseViewController
            diagnoseVC.capturedImages = capturedImages
        }
    }
    
    @IBAction func unwindFromDiagnosis(segue: UIStoryboardSegue) {
        if segue.identifier == UnwindFromDiagnosisSegueIdentifier {
            capturedImages.removeAll()
            stopCapturing = false
        }
    }

}
