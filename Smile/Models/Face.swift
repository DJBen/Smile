//
//  Face.swift
//  Smile
//
//  Created by Sihao Lu on 4/26/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit

class Face: NSObject, Printable {
    enum StrokeStatus: String {
        case Positive = "Positive"
        case Negative = "Negative"
    }
    
    struct Positions: Printable {
        let leftEye: CGPoint
        let rightEye: CGPoint
        let mouthLeftEdge: CGPoint
        let mouthRightEdge: CGPoint
        
        var description: String {
            get {
                return "{leftEye = \(leftEye), rightEye = \(rightEye), mouthLeft = \(mouthLeftEdge), mouthRight = \(mouthRightEdge)}"
            }
        }
        
        init() {
            leftEye = CGPointZero
            rightEye = CGPointZero
            mouthLeftEdge = CGPointZero
            mouthRightEdge = CGPointZero
        }
        
        init(leftEye: CGPoint, rightEye: CGPoint, mouthLeftEdge: CGPoint, mouthRightEdge: CGPoint) {
            self.leftEye = leftEye
            self.rightEye = rightEye
            self.mouthLeftEdge = mouthLeftEdge
            self.mouthRightEdge = mouthRightEdge
        }
    }
    
    enum Gender: String {
        case Male = "Male"
        case Female = "Female"
    }
    
    override var description: String {
        get {
            return "Face = {age = {\(age), \(ageRange)}, smiling = \(smiling), positions = \(positions)}"
        }
    }
    
    let age: Int
    let ageRange: Int
    let smiling: Double
    
    let positions: Positions
    
    var distortion: CGFloat {
        get {
            let eyeSlope = (positions.rightEye.y - positions.leftEye.y) / (positions.rightEye.x - positions.leftEye.x)
            let mouthSlope = (positions.mouthRightEdge.y - positions.mouthLeftEdge.y) / (positions.mouthRightEdge.x - positions.mouthLeftEdge.x)
            return eyeSlope - mouthSlope
        }
    }
    
    var result: StrokeStatus {
        get {
            if abs(distortion) > 0.06 {
                return .Positive
            } else {
                return .Negative
            }
        }
    }
    
    var isDummy: Bool {
        return age == 0
    }
    
    override init() {
        age = 0
        ageRange = 0
        smiling = 0
        positions = Positions()
        super.init()
    }
    
    init?(dictionary: [String: AnyObject]) {
        if let attributes = dictionary["attribute"] as? [String: AnyObject], positionInfo = dictionary["position"] as? [String: AnyObject] {
            if let ageInfo = attributes["age"] as? [String: Int], smilingInfo = attributes["smiling"] as? [String: AnyObject] {
                age = ageInfo["value"]!
                ageRange = ageInfo["range"]!
                smiling = smilingInfo["value"] as! Double
                if let eyeLeftInfo = positionInfo["eye_left"] as? [String: Double], eyeRightInfo = positionInfo["eye_right"] as? [String: Double], mouthLeftInfo = positionInfo["mouth_left"] as? [String: Double], mouthRightInfo = positionInfo["mouth_right"] as? [String: Double] {
                    let eyeLeft = CGPointMake(CGFloat(eyeLeftInfo["x"]!), CGFloat(eyeLeftInfo["y"]!))
                    let eyeRight = CGPointMake(CGFloat(eyeRightInfo["x"]!), CGFloat(eyeRightInfo["y"]!))
                    let mouthLeft = CGPointMake(CGFloat(mouthLeftInfo["x"]!), CGFloat(mouthLeftInfo["y"]!))
                    let mouthRight = CGPointMake(CGFloat(mouthRightInfo["x"]!), CGFloat(mouthRightInfo["y"]!))
                    positions = Positions(leftEye: eyeLeft, rightEye: eyeRight, mouthLeftEdge: mouthLeft, mouthRightEdge: mouthRight)
                    super.init()
                } else {
                    println("Parse face: error 1")
                    positions = Positions()
                    super.init()
                    return nil
                }
            } else {
                println("Parse face: error 2")
                age = 0
                ageRange = 0
                smiling = 0
                positions = Positions()
                super.init()
                return nil
            }
        } else {
            println("3")
            age = 0
            ageRange = 0
            smiling = 0
            positions = Positions()
            super.init()
            return nil
        }
    }
    
    class func facesFromDictionary(dictionary: [String: AnyObject]) -> [Face] {
        var faces: [Face] = [Face]()
        if let rawFaces = dictionary["face"] as? [[String: AnyObject]] {
            for rawFace in rawFaces {
                if let face = Face(dictionary: rawFace) {
                    faces.append(face)
                }
            }
        }
        return faces
    }
}
