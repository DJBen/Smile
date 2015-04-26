//
//  UIImage+SampleBuffer.h
//  Smile
//
//  Created by Sihao Lu on 4/23/15.
//  Copyright (c) 2015 Sihao Lu. All rights reserved.
//
//  Code extracted from the AVFoundation Guide of Apple, https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface UIImage (SampleBuffer)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end
