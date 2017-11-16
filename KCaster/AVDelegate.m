//
//  AVDelegate.m
//  KCaster
//
//  Created by James Forrester on 1/23/17.
//  Copyright © 2017 James Forrester. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AVDelegate.h"
#import <AWSKinesis/AWSKinesis.h>

@implementation AVDelegate {

    AWSKinesis* kinesis;
    AWSKinesisRecorder *kinesisRecorder;
    int frameCounter;

}

-(void) captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
    frameCounter++;
    if (frameCounter != 100)
    {
        return;
    }
    frameCounter = 0;
    
    if (kinesis == nil)
    {
        kinesis = [AWSKinesis alloc];
        
        kinesisRecorder = [AWSKinesisRecorder defaultKinesisRecorder];
        

        [[[kinesisRecorder removeAllRecords] continueWithSuccessBlock:^id(AWSTask *task) {
            
            return task;
        }] continueWithBlock:^id(AWSTask *task) {
            if (task.error) {
                NSLog(@"Error: %@", task.error);
            }
            NSLog(@"Records cleared");
            return nil;
        }];
        
        kinesisRecorder.diskAgeLimit = 30 * 24 * 60 * 60; // 30 days
        kinesisRecorder.diskByteLimit = 10 * 1024 * 1024; // 10MB
        kinesisRecorder.notificationByteThreshold = 5 * 1024 * 1024; // 5MB
        
    }
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
    CGSize imageSize = CVImageBufferGetEncodedSize( imageBuffer );
    // also in the 'mediaSpecific' dict of the sampleBuffer
    
    UIImage *theImage = [self imageFromSampleBuffer:sampleBuffer];
    NSData *imageData = UIImageJPEGRepresentation(theImage,0.5);
    
    NSLog( @"frame captured at %.fx%.f", imageSize.width, imageSize.height );
    
    [[[kinesisRecorder saveRecord:imageData
                       streamName:@"<Kinesis stream NAME (not ID/ARN) from CloudFormation>"] continueWithSuccessBlock:^id(AWSTask *task) {

        return [kinesisRecorder submitAllRecords];
    }] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        return nil;
    }];

}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
