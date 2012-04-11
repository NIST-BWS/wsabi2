//
//  NBCLInternalCameraSensorLink.m
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

#import "NBCLInternalCameraSensorLink.h"

@implementation NBCLInternalCameraSensorLink

@synthesize previewLayer, pseudoResult, captureManager, currentCapturedImageData;

-(id) init
{
	if ((self = [super init])) {
        
        //create the placeholder WSBDResult
        self.pseudoResult = [[WSBDResult alloc] init];
        self.pseudoResult.sessionId = @"1234";
        self.pseudoResult.captureIds = [NSArray arrayWithObject:@"7890"];
    }
    return self;
}
   
#pragma mark - Property accessors
-(AVCaptureVideoPreviewLayer*) previewLayer
{
    if (!self.captureManager) {
        //Create a capture manager.
        NSError *error = nil;
        self.captureManager = [[AVCamDemoCaptureManager alloc] init];
        if ([self.captureManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error]) {
            
            previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
            if ([previewLayer isOrientationSupported]) {
                [previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
            }
            
            [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            
            
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Couldn't create preview layer."
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            [alertView show];
        }        
    }
    
    return previewLayer;
}

#pragma mark - Convenience methods to combine multiple steps
-(BOOL) beginConnectSequence:(NSURL*)sourceObjectID
{
    if (self.sequenceInProgress) {
        //don't start another sequence if one is in progress
        return NO;
    }
    
    //kick off the connection sequence
    self.sequenceInProgress = YES;
    [self beginRegisterClient:sourceObjectID];
    return YES;
    
}

-(BOOL) beginCaptureSequence:(NSString *)sessionId captureType:(int)captureType withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID
{
    if (self.sequenceInProgress) {
        //don't start another sequence if one is in progress
        return NO;
    }
    
    //kick off the capture sequence
    self.sequenceInProgress = YES;
    downloadMaxSize = maxSize;
    [self beginConfigure:self.currentSessionId 
          withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[WSModalityMap parameterNameForCaptureType:captureType],@"submodality",nil] 
           sourceObjectID:sourceID];
    
    return YES;
}

-(BOOL) beginDisconnectSequence:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
    if (self.sequenceInProgress) {
        //don't start another sequence if one is in progress
        return NO;
    }
    
    //kick off the disconnect sequence
    self.sequenceInProgress = YES;
    [self beginUnlock:self.currentSessionId sourceObjectID:sourceID];
    return YES;
    
}

#pragma mark -
#pragma mark Methods to start various operations.

//Register
-(void) beginRegisterClient:(NSURL *)sourceObjectID
{
    NSLog(@"Calling beginRegister");
    operationInProgress = kOpTypeRegister;
    
 	NSLog(@"Completed registration request successfully.");
    [self.delegate sensorOperationCompleted:kOpTypeRegister 
                              fromLink:self
                             sourceObjectID:sourceObjectID
                                 withResult:self.pseudoResult];
    //set the registered convenience variable.
    self.registered = YES;
    //store the current session id.
    self.currentSessionId = self.pseudoResult.sessionId;
    //if this call is part of a sequence, call the next step.
    if (self.sequenceInProgress) {
        [self beginLock:self.currentSessionId sourceObjectID:sourceObjectID];
    }
    
    operationInProgress = -1;
    
}

-(void) beginUnregisterClient:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{	
    NSLog(@"Calling beginUnregister");

    operationInProgress = kOpTypeUnregister;
    
	NSLog(@"Completed unregister request successfully.");
    self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
    
    [self.delegate sensorOperationCompleted:kOpTypeUnregister 
                              fromLink:self sourceObjectID:sourceID withResult:self.pseudoResult];
    
    //set the registered convenience variable.
    self.registered = NO;
    
    //notify the delegate that we're no longer "connected and ready"
    //NOTE: This may also be done in the unlock method, but there's no guarantee that unlock will be called.
    [self.delegate sensorConnectionStatusChanged:NO fromLink:self sourceObjectID:sourceID];
    
    //clear the current session id.
    self.currentSessionId = nil;
    
    //if this call is part of a sequence, notify our delegate that the sequence is complete.
    if (self.sequenceInProgress) {
        self.sequenceInProgress = NO;
        [self.delegate disconnectSequenceCompletedFromLink:self 
                                                withResult:self.pseudoResult 
                                            sourceObjectID:sourceID];
    }
    
    operationInProgress = -1;
    

}


//Lock
-(void) beginLock:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginLock");

    operationInProgress = kOpTypeLock;

	NSLog(@"Completed lock request successfully.");
    
    [self.delegate sensorOperationCompleted:kOpTypeLock 
                              fromLink:self 
                                sourceObjectID:sourceID
                                 withResult:self.pseudoResult];
    
    //set the lock convenience variable.
    self.hasLock = YES;
    
    //if this call is part of a sequence, call the next step.
    if (self.sequenceInProgress) {
        [self beginInitialize:self.currentSessionId sourceObjectID:sourceID];
    }
    
    operationInProgress = -1;
}

-(void) beginStealLock:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginStealLock");

	operationInProgress = kOpTypeStealLock;

 	NSLog(@"Completed steal lock request successfully.");
    
    //set the lock convenience variable.
    self.hasLock = YES;
    
    //if this call is part of a sequence, call the next step.
    if (self.sequenceInProgress) {
        [self beginInitialize:self.currentSessionId sourceObjectID:sourceID];
    }
    operationInProgress = -1;

}

-(void) beginUnlock:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginUnlock");

    operationInProgress = kOpTypeUnlock;

	NSLog(@"Completed unlock request successfully.");
    
    //set the lock convenience variable.
    self.hasLock = NO;
    
    //notify the delegate that we're no longer "connected and ready"
    //NOTE: This will also be called in the unregister method, as there's no guarantee that the unlock method will be called.
    [self.delegate sensorConnectionStatusChanged:NO fromLink:self sourceObjectID:sourceID];
    
    //if this call is part of a sequence, call the next step.
    if (self.sequenceInProgress) {
        [self beginUnregisterClient:self.currentSessionId sourceObjectID:sourceID];
    }

}


//Info
-(void) beginGetCommonInfo:(NSURL *)sourceObjectID
{
	NSLog(@"Calling beginCommonInfo");

	operationInProgress = kOpTypeGetCommonInfo;
    
 	NSLog(@"Completed common info request successfully.");
    
    [self.delegate sensorOperationCompleted:kOpTypeGetCommonInfo 
                              fromLink:self 
                             sourceObjectID:sourceObjectID 
                                 withResult:self.pseudoResult];
 
    operationInProgress = -1;
    
}

-(void) beginGetDetailedInfo:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginGetInfo");
 
	operationInProgress = kOpTypeGetDetailedInfo;
    
 	NSLog(@"Completed detailed info request successfully.");

    [self.delegate sensorOperationCompleted:kOpTypeGetDetailedInfo
                              fromLink:self sourceObjectID:sourceID withResult:self.pseudoResult];
 
    operationInProgress = -1;
    
    
}

//Initialize
-(void) beginInitialize:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginInitialize");

	operationInProgress = kOpTypeInitialize;
    
    NSLog(@"Completed initialize request successfully.");

    //set the lock convenience variable.
    self.initialized = YES;
    
    //notify the delegate that our status is now "connected and ready"
    [self.delegate sensorConnectionStatusChanged:YES fromLink:self sourceObjectID:sourceID];
   
    //if this call is part of a sequence, notify our delegate that the sequence is complete.
    if (self.sequenceInProgress) {
        self.sequenceInProgress = NO;
        [self.delegate connectSequenceCompletedFromLink:self withResult:self.pseudoResult sourceObjectID:sourceID];
    }
    operationInProgress = -1;

}

//Configure
-(void) beginGetConfiguration:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginGetConfiguration");

	operationInProgress = kOpTypeGetConfiguration;

    NSLog(@"Completed get config request successfully.");

    [self.delegate sensorOperationCompleted:kOpTypeGetConfiguration 
                              fromLink:self sourceObjectID:sourceID withResult:self.pseudoResult];
    operationInProgress = -1;
    
}

-(void) beginConfigure:(NSString*)sessionId withParameters:(NSDictionary*)params sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginConfigure");

	operationInProgress = kOpTypeConfigure;
    
	NSLog(@"Completed set config request successfully.");

    [self.delegate sensorOperationCompleted:kOpTypeConfigure 
                              fromLink:self sourceObjectID:sourceID withResult:self.pseudoResult];

    //if this call is part of a sequence, call the next step.
    if (self.sequenceInProgress) {
        //begin capture
        [self beginCapture:self.currentSessionId sourceObjectID:sourceID];
    }
  
    operationInProgress = -1;

}


//Capture
-(void) beginCapture:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginCapture");
    
	operationInProgress = kOpTypeCapture;
    
    //perform the actual capture
    AVCaptureConnection *videoConnection = [AVCamDemoCaptureManager connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self.captureManager stillImageOutput] connections]];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    [[self.captureManager stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                                        completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                                            if (imageDataSampleBuffer != NULL) {
                                                                                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                                self.currentCapturedImageData = imageData;       
                                                                                NSLog(@"Completed capture request successfully.");
                                                                                
                                                                                //NOTE: We're not storing any real captureIds here, so we're only working with
                                                                                //ONE capture result at a time.
                                                                                //This is really only useful for testing.
                                                                                [self.delegate sensorOperationCompleted:kOpTypeCapture 
                                                                                                          fromLink:self sourceObjectID:sourceID withResult:self.pseudoResult];
                                                                                
                                                                                //if this call is part of a sequence, call the next step.
                                                                                if (self.sequenceInProgress) {
                                                                                    [self beginDownload:[self.pseudoResult.captureIds objectAtIndex:0] withMaxSize:downloadMaxSize sourceObjectID:sourceID];
                                                                                }
                                                                                
                                                                                operationInProgress = -1;

                                                                            } 
                                                                            else if (error) {
                                                                                self.currentCapturedImageData = nil;
                                                                            }
                                                                        }];

    //add an indicator that a picture is being taken.
    UIView *captureInProgressView = [[UIView alloc] initWithFrame:self.previewLayer.frame];
    captureInProgressView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    captureInProgressView.layer.name = @"captureInProgressLayer";
    [self.previewLayer addSublayer:captureInProgressView.layer];
}

-(void) beginGetCaptureInfo:(NSString*)captureId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginGetCaptureInfo");

    operationInProgress = kOpTypeGetContentType;
    
    NSLog(@"Completed get capture info request successfully.");
    
   [self.delegate sensorOperationCompleted:kOpTypeGetContentType 
                             fromLink:self sourceObjectID:sourceID withResult:self.currentWSBDResult];
    
    operationInProgress = -1;

}



//Download
-(void) beginDownload:(NSString*)captureId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginDownload");

	operationInProgress = kOpTypeDownload;
    
    NSLog(@"Completed download request successfully.");
    
    //build a WSBDResult containing a full-sized PNG version of the image.
    WSBDResult *result = [[WSBDResult alloc] init];
    result.status = StatusSuccess;
    result.captureIds = [NSArray arrayWithObject:captureId];
    if (self.currentCapturedImageData) {
        result.contentType = @"image/jpeg"; //this is what comes back from the camera.
        result.downloadData = self.currentCapturedImageData;
    }
    
    [self.delegate sensorOperationCompleted:kOpTypeDownload 
                              fromLink:self sourceObjectID:sourceID withResult:result];

    //remove the indicator that a picture is being taken.
    for (CALayer *layer in self.previewLayer.sublayers) {
        if ([layer.name isEqualToString:@"captureInProgressLayer"]) {
            [layer removeFromSuperlayer];
        }
    }

    if (self.sequenceInProgress) {
        self.sequenceInProgress = NO;
        [self.delegate configCaptureDownloadSequenceCompletedFromLink:self withResults:[NSMutableArray arrayWithObject:result] sourceObjectID:sourceID];

    }
    operationInProgress = -1;
}

-(void) beginDownload:(NSString*)captureId withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginDownload:withMaxSize");
    
	operationInProgress = kOpTypeThriftyDownload;
    
    NSLog(@"Completed download:withMaxSize request successfully.");
    
    //build a WSBDResult containing a resized PNG version of the image.
    WSBDResult *result = [[WSBDResult alloc] init];
    result.status = StatusSuccess;
    result.captureIds = [NSArray arrayWithObject:captureId];
    if (self.currentCapturedImageData) {
        result.contentType = @"image/png"; //this is what comes back from the camera.
        UIImage *tempImage = [UIImage scaleImage:[UIImage imageWithData:self.currentCapturedImageData] 
                                          toSize:CGSizeMake(maxSize, maxSize)];
        result.downloadData = UIImagePNGRepresentation(tempImage);
    }
    
    [self.delegate sensorOperationCompleted:kOpTypeThriftyDownload 
                              fromLink:self sourceObjectID:sourceID withResult:result];
    
    //remove the indicator that a picture is being taken.
    for (CALayer *layer in self.previewLayer.sublayers) {
        if ([layer.name isEqualToString:@"captureInProgressLayer"]) {
            [layer removeFromSuperlayer];
        }
    }

    if (self.sequenceInProgress) {
        self.sequenceInProgress = NO;
        [self.delegate configCaptureDownloadSequenceCompletedFromLink:self withResults:[NSMutableArray arrayWithObject:result] sourceObjectID:sourceID];
        
    }
    operationInProgress = -1;
}

//Cancel
-(void) beginCancel:(NSString*)sessionId sourceObjectID:(NSURL *)sourceID
{
	NSLog(@"Calling beginCancel");

    //NOTE: We're completely faking this method, as there's no service running operations to cancel.
    [self.delegate sensorOperationCompleted:kOpTypeCancel 
                              fromLink:self sourceObjectID:sourceID withResult:self.pseudoResult];
    
    //stop any sequence that was in progress.
    self.sequenceInProgress = NO;
    
    //Fire sensorOperationWasCancelled* in the delegate, and pass the opType
    //of the CANCELLED operation. 
    [self.delegate sensorOperationWasCancelledByClient:operationInProgress fromLink:self sourceObjectID:sourceID];

    operationInProgress = -1;

}


//-(void) dealloc
//{
//    [super dealloc];
//    [pseudoResult release];
//    [captureManager release];
//}

@end
