//
//  AVDelegate.h
//  KCaster
//
//  Created by James Forrester on 1/23/17.
//  Copyright © 2017 James Forrester. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#ifndef AVDelegate_h
#define AVDelegate_h

@interface AVDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    // Protected instance variables (not recommended)
}

-(void) captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection;

@end

#endif /* AVDelegate_h */
