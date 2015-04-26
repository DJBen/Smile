//
//  CameraPreviewView.swift
//  Smile
//
//  Created by Sihao Lu on 4/23/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol CameraPreviewViewDelegate {
    optional func requestCameraFocusChangeToPoint(point: CGPoint, inView pointInView: CGPoint)
}

class CameraPreviewView: UIView {
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        return tapRecognizer
    }()
    
    var session: AVCaptureSession {
        get {
            return (self.layer as! AVCaptureVideoPreviewLayer).session
        }
        set {
            (self.layer as! AVCaptureVideoPreviewLayer).session = newValue
        }
    }
    
    var delegate: CameraPreviewViewDelegate?
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    // MARK: - Event Handling
    
    func tapped(sender: UIGestureRecognizer) {
        var pointInPreview = sender.locationInView(sender.view)
        var pointInCamera = (self.layer as! AVCaptureVideoPreviewLayer).captureDevicePointOfInterestForPoint(pointInPreview)
        delegate?.requestCameraFocusChangeToPoint?(pointInCamera, inView: pointInPreview)
    }

    // MARK: - Private Methods
    private func configureView() {
        userInteractionEnabled = true
        addGestureRecognizer(tapRecognizer)
    }
}
