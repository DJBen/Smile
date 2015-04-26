//
//  DiagnoseViewController.swift
//  Smile
//
//  Created by Sihao Lu on 4/26/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography
import Alamofire

class DiagnoseViewController: UIViewController {
    
    static var imageViewWidth: CGFloat {
        let maxHeight = UIScreen.mainScreen().bounds.size.height
        let iPhone6OrMore = maxHeight > 568.0
        return iPhone6OrMore ? 180 : 140
    }
    
    lazy var backgroundImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "blue_gradient"))
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: CGRectMake(0, 0, 1000, 1000))
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.scrollEnabled = true
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return view
    }()
    
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
    
    lazy var homeButton: UIButton = {
        let button = UIButton.buttonWithType(.System) as! UIButton
        button.setTitle("Home", forState: .Normal)
        button.titleLabel!.font = UIFont.freightSansFontWithStyle(.Book, size: 22)
        button.addTarget(self, action: "homeButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.freightSansFontWithStyle(.Light, size: 23)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .ByTruncatingTail
        label.layer.shadowColor = UIColor.whiteColor().CGColor
        label.layer.shadowOpacity = 0.3
        label.layer.shadowRadius = 5
        label.textAlignment = .Center
        return label
    }()
    
    var capturedImages: [UIImage]!

    private var imageStatusViews: [ImageStatusView] = [ImageStatusView]()
    private var retryButtons: [UIButton] = [UIButton]()
    private(set) var faces: [Int: Face] = [Int: Face]()
    private var requests: [Int: Request] = [Int: Request]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        analyzeFaces()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Events
    func shareActionTapped(sender: UIBarButtonItem) {
        let textToShare = "I used #Smile to diagnose stroke!"
        let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func homeButtonTapped(sender: UIButton) {
        cancelUploading()
        performSegueWithIdentifier(UnwindFromDiagnosisSegueIdentifier, sender: self)
    }
    
    func retryTapped(sender: UIButton) {
        let index = sender.tag
        println("Retry at \(index) tapped.")
        if let face = faces[index] where face.isDummy {
            if let request = requests[index] {
                request.cancel()
            }
            analyzeFaceAtIndex(index, image: capturedImages[index])
        }
    }
    
    // MARK: - Private Methods
    
    private func analyzeFaces() {
        for (i, image) in enumerate(capturedImages) {
            analyzeFaceAtIndex(i, image: image)
        }
    }
    
    private func analyzeFaceAtIndex(index: Int, image: UIImage) {
        let request = Detector.detectFacesWithImage(image, tag: index, progress: { (progress: Double) in
            if progress >= 1 {
                self.imageStatusViews[index].status = .ServerAnalyzing
            } else {
                self.imageStatusViews[index].status = .Uploading(progress)
            }
            }, completion: { (tag, faces, error) -> Void in
                if error == nil {
                    if let theFaces = faces where !theFaces.isEmpty {
                        let face = theFaces[0]
                        self.imageStatusViews[tag].status = .ResultReady(face.result)
                        println("Distortion: \(face.distortion)")
                        self.faces[tag] = face
                    } else {
                        self.imageStatusViews[tag].status = .Error
                        self.faces[tag] = Face()
                    }
                } else {
                    self.imageStatusViews[tag].status = .Error
                    self.faces[tag] = Face()
                }
                self.requests[tag] = nil
                self.refreshResult()
        })
        requests[index] = request
    }
    
    private func cancelUploading() {
        for (i, request) in requests {
            request.cancel()
        }
    }
    
    private func refreshResult() {
        let count = capturedImages.count
        var notFinished = false
        for i in 0..<count {
            if faces[i] == nil {
                notFinished = true
                break
            }
        }
        if notFinished {
            resultLabel.textColor = UIColor(white: 0, alpha: 0.8)
            resultLabel.text = "Please wait for the diagnosis."
            return
        }
        var hasError = false
        for i in 0..<count {
            if faces[i]!.isDummy {
                hasError = true
                break
            }
        }
        if hasError {
            resultLabel.textColor = UIColor(white: 0, alpha: 0.8)
            resultLabel.text = "It appears that some of the images encountered errors, please tap the according item to retry."
            return
        }
        var positiveCount = 0, negativeCount = 0
        for i in 0..<count {
            if faces[i]!.result == .Positive {
                positiveCount++
            } else {
                negativeCount++
            }
        }
        if positiveCount >= negativeCount {
//            resultLabel.textColor = UIColor.SmileColor(.Red)
            resultLabel.text = "You may be under risk of having a stroke. Contact your doctor, and call emergency services if necessary."
        } else {
//            resultLabel.textColor = UIColor.SmileColor(.Green)
            resultLabel.text = "Great! It seems you don't have a stroke."
        }
    }
    
    private func configureViews() {
        navigationItem.title = "Diagnose"
        navigationItem.hidesBackButton = true
        let shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareActionTapped:")
        navigationItem.rightBarButtonItem = shareButton
        
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        view.addSubview(blurView)
        view.addSubview(resultLabel)
        blurView.contentView.addSubview(vibrantView)
        vibrantView.contentView.addSubview(homeButton)
        
        layout(homeButton) { v in
            v.edges == v.superview!.edges
        }
        
        layout(vibrantView) { v in
            v.edges == v.superview!.edges
        }
        
        constrain(blurView, resultLabel, scrollView) { v, r, s in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.bottom == v.superview!.bottom
            v.height == 54
            
            r.left == r.superview!.left + 30
            r.right == r.superview!.right - 30
            r.top == s.bottom + 30
            r.bottom == v.top - 20
        }
        
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 40))
        
        layout(backgroundImageView, scrollView) { b, s in
            b.edges == b.superview!.edges
            s.left == s.superview!.left
            s.right == s.superview!.right
            s.height == DiagnoseViewController.imageViewWidth * 1280 / 720
        }
        
        addImageStatusViews()
    }
    
    private func addImageStatusViews() {
        for view in imageStatusViews {
            view.removeFromSuperview()
        }
        imageStatusViews.removeAll()
        for button in retryButtons {
            button.removeFromSuperview()
        }
        retryButtons.removeAll()
        let width: CGFloat = DiagnoseViewController.imageViewWidth
        let interspacing: CGFloat = 16
        let height = width * 1280 / 720
        scrollView.contentSize = CGSizeMake(width * CGFloat(capturedImages.count) + interspacing * CGFloat(capturedImages.count - 1), height)
        for (i, image) in enumerate(capturedImages) {
            let imageStatusView = ImageStatusView(frame: CGRectMake(CGFloat(i) * (width + interspacing), 0, width, height))
            scrollView.addSubview(imageStatusView)
            imageStatusView.image = image
            imageStatusViews.append(imageStatusView)
            let retryButton = UIButton.buttonWithType(.Custom) as! UIButton
            retryButton.backgroundColor = UIColor.clearColor()
            retryButton.frame = imageStatusView.frame
            retryButton.tag = i
            retryButton.addTarget(self, action: "retryTapped:", forControlEvents: .TouchUpInside)
            scrollView.addSubview(retryButton)
            retryButtons.append(retryButton)
        }
        scrollView.setContentOffset(CGPointZero, animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
