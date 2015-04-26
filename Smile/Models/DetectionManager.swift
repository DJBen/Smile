//
//  DetectionManager.swift
//  Smile
//
//  Created by Sihao Lu on 4/26/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//

import UIKit
import Alamofire

let Detector: DetectionManager = DetectionManager.sharedManager

class DetectionManager: NSObject {
    private let apiKey = "e9f124844e73e079ed668d867100ef2e"
    private let apiSecret = "1nIEMtSYBLkdNMqIkZ8-SWkENkMzttz5"
    private let apiUrl = "http://apius.faceplusplus.com/"
    
    class var sharedManager : DetectionManager {
        struct Static {
            static let instance : DetectionManager = DetectionManager()
        }
        return Static.instance
    }
        
    func detectFacesWithImage(image: UIImage, tag: Int = 0, progress: ((progress: Double) -> Void)? = nil, completion: (tag: Int, faces: [Face]?, error: NSError?) -> Void) -> Request {
        let detectionApiUrl = apiUrl.stringByAppendingPathComponent("detection/detect")
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let parameters: [String: String] = ["api_key" : self.apiKey, "api_secret": self.apiSecret, "mode": "oneface", "attributes": "smiling", "async": "false"]
        let (urlString, data) = self.urlRequestWithComponents(detectionApiUrl, parameters: parameters, imageData: imageData)
        let request = upload(urlString, data).progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            println("Uploading \(totalBytesWritten) / \(totalBytesExpectedToWrite) = \(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100) %")
            let percentage: Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            dispatch_async(dispatch_get_main_queue()) {
                progress?(progress: percentage)
            }
            }.responseJSON { (request, response, JSON, error) -> Void in
                if error != nil {
                    println("ERROR \(error)")
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(tag: tag, faces: nil, error: error)
                    }
                    return
                }
                println("JSON \(JSON)")
                let faces = Face.facesFromDictionary(JSON as! [String: AnyObject])
                println(faces)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(tag: tag, faces: faces, error: nil)
                }
        }
        return request
    }
    
    // Convenient method to upload image
    // http://stackoverflow.com/questions/26121827/uploading-file-with-parameters-using-alamofire
    private func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"img\"; filename=\"file.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
}

extension UIImage {

}
