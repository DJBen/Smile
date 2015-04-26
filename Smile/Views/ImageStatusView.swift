//
//  ImageStatusView.swift
//  Smile
//
//  Created by Sihao Lu on 4/26/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Cartography

class ImageStatusView: UIView {
    
    enum ImageStatus {
        case Error
        case NotStarted
        case Uploading(Double)
        case ServerAnalyzing
        case ResultReady(Face.StrokeStatus)
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var status: ImageStatus = .NotStarted {
        willSet {
            switch newValue {
            case .ResultReady(let result):
                if result == .Positive {
                    smileView.smiling = false
                } else {
                    smileView.smiling = true
                }
            default:
                smileView.smiling = true
            }
            switch newValue {
            case .NotStarted:
                self.progress = 0
                statusTextLabel.text = "Waiting..."
                smileView.disappear()
            case .Uploading(let progress):
                self.progress = progress
                let percentageText = NSString(format: "%.0f", progress * 100)
                statusTextLabel.text = "Uploading \(percentageText)%"
            case .ServerAnalyzing:
                self.progress = 1
                statusTextLabel.text = "Analyzing..."
            case .ResultReady(let result):
                self.progress = 1
                statusTextLabel.text = "\(result.rawValue)"
                smileView.appear()
                self.progress = 0
                if result == .Positive {
                    statusTextLabel.textColor = UIColor.SmileColor(.Red)
                    smileView.tintColor = UIColor.SmileColor(.Red)
                } else {
                    statusTextLabel.textColor = UIColor.SmileColor(.Green)
                    smileView.tintColor = UIColor.SmileColor(.Green)
                }
            case .Error:
                self.progress = 0
                statusTextLabel.text = "Tap to retry"
            }
        }
    }

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var statusTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting..."
        label.font = UIFont.freightSansFontWithStyle(.Book, size: 21)
        label.numberOfLines = 1
        label.textAlignment = .Center
        label.lineBreakMode = .ByTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.whiteColor()
        label.minimumScaleFactor = 0.5
        label.layer.shadowRadius = 5
        label.layer.shadowColor = UIColor(white: 0, alpha: 0.6).CGColor
        return label
    }()
    
    lazy var smileView: SmileIconView = {
        let view = SmileIconView()
        view.tintColor = UIColor.whiteColor()
        view.disappear(animated: false)
        return view
    }()
    
    lazy var progressCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return view
    }()
    
    var progress: Double = 0 {
        willSet {
            if progressHeightConstraint != nil {
                progressCoverView.removeConstraint(progressHeightConstraint!)
                removeConstraint(progressHeightConstraint!)
            }
            layout(progressCoverView) { p in
                self.progressHeightConstraint = (p.height == p.superview!.height * (1 - newValue))
            }
        }
    }
    
    private var progressHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Private Methods
    private func configureView() {
        addSubview(imageView)
        addSubview(progressCoverView)
        addSubview(smileView)
        addSubview(statusTextLabel)
        
        constrain(imageView, progressCoverView) { i, p in
            i.edges == i.superview!.edges
            if self.progressHeightConstraint == nil {
                self.progressHeightConstraint = (p.height == p.superview!.height * self.progress)
            }
            p.left == p.superview!.left
            p.right == p.superview!.right
            p.top == p.superview!.top
        }
        
        layout(smileView, statusTextLabel) { s, t in
            s.center == s.superview!.center
            s.width == s.height
            s.width == 48
            
            t.bottom == t.superview!.bottom - 8
            t.left == t.superview!.leftMargin + 8
            t.right == t.superview!.rightMargin - 8
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
