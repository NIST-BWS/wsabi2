//
//  NBCLInternalCameraSensorLink.h
//  wsabi
//
//  Created by Matt Aronoff on 4/27/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */

// Updated Feb 2012 for ARC support

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "NBCLDeviceLink.h"
#import "AVCamDemoCaptureManager.h"
#import "UIImage+NBCLExtras.h"

@class AVCamDemoCaptureManager;

@interface NBCLInternalCameraSensorLink : NBCLDeviceLink {
    AVCaptureVideoPreviewLayer *previewLayer;
    
    WSBDResult *pseudoResult;
    AVCamDemoCaptureManager *captureManager; //an initialized captureManager object capable of capturing data.
    NSData *currentCapturedImageData;
}

@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) WSBDResult *pseudoResult;
@property (nonatomic, strong) AVCamDemoCaptureManager *captureManager;
@property (nonatomic, strong) NSData *currentCapturedImageData;

@end
