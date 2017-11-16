//
//  ViewController.m
//  KCaster
//
//  Created by James Forrester on 1/23/17.
//  Copyright © 2017 James Forrester. All rights reserved.
//

#import "ViewController.h"
#import "AVDelegate.h"

@interface ViewController ()

@end

@implementation ViewController {
    AVDelegate *avd;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    avd = [[AVDelegate alloc ] init];
    
    // make input device
    NSError *deviceError;
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    /*
    cameraDevice.lockForConfiguration();
    cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(5,1);
    cameraDevice.activeVideoMinFrameDuration = CMTimeMake(5,1);
    cameraDevice.unlockForConfiguration();
    */
    
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&deviceError];
    
    // make output device
    AVCaptureVideoDataOutput *outputDevice = [[AVCaptureVideoDataOutput alloc] init];
    outputDevice.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey: (id)kCVPixelBufferPixelFormatTypeKey];
    
    [outputDevice setSampleBufferDelegate:avd queue:dispatch_get_main_queue()];
    
    // initialize capture session
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    [captureSession addInput:inputDevice];
    [captureSession addOutput:outputDevice];
    
    // make preview layer and add so that camera's view is displayed on screen
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.frame = self.view.bounds;
    
    [self.view.layer addSublayer:previewLayer];
    
    // go!
    [captureSession startRunning];
    NSLog(@"Running");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
