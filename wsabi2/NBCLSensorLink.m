//
//  NBCLSensorLink.m
//  Wsabi
//
//  Created by Matt Aronoff on 3/24/10.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */

// Updated Feb 2012 for ARC support

#import "NBCLSensorLink.h"


@implementation NBCLSensorLink
@synthesize delegate;
@synthesize registered, hasLock, initialized, sequenceInProgress;
@synthesize shouldRetryDownloadIfPending;
@synthesize uri, currentSessionId, networkTimeout;

@synthesize mainNamespace, schemaInstanceNamespace, schemaNamespace;

@synthesize exponentialIntervalMax;
@synthesize currentParseResult, currentElementName, currentElementValue, currentContainerArray, currentContainerDictionary, currentDictionaryKey, currentDictionaryValue;
@synthesize captureIds;
@synthesize downloadSequenceResults;
@synthesize acceptableContentTypes;

-(id) init
{
	if ((self = [super init])) {
		self.captureIds = [[NSMutableArray alloc] init];
		responseData = [NSMutableData data];
        
        cancelResponseData = [NSMutableData data];
        
        self.mainNamespace = @"xmlns=\"urn:oid:2.16.840.1.101.3.9.3.1\"";
        self.schemaInstanceNamespace = @"xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"";
        self.schemaNamespace = @"xmlns:xs=\"http://www.w3.org/2001/XMLSchema\"";
        
        operationInProgress = -1; //nothing currently in progress.
		operationPendingCancellation = -1; //nothing currently in the process of being cancelled.
        
		//initialize and configure the network queue.
		networkQueue = [[ASINetworkQueue alloc] init];
		[networkQueue setMaxConcurrentOperationCount:1]; //perform operations sequentially.
		//make sure we remove all other requests if something in the chain fails.
		//This prevents, for example, capturing with the wrong parameters if configure fails.
		[networkQueue setShouldCancelAllRequestsOnFailure:YES];
		[networkQueue setDelegate:self]; //in case we want finish/fail selectors later.
		[networkQueue go];
		
		//get the list of acceptable MIME types from the user prefs.
		self.acceptableContentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:@"acceptableContentTypes"];
        
        downloadRetryCount = [[NSMutableDictionary alloc] init];
        //This should retrieve the expected maximum processing time from commonInfo
        self.exponentialIntervalMax = 30; //seconds

        //set a default timeout for all network operations.
        self.networkTimeout = 30; //this is an NSTimeInterval, and is therefore in seconds.
        
        //start with all convenience variables set to NO
        self.registered = NO;
        self.hasLock = NO;
        self.initialized = NO;
        
        self.sequenceInProgress = NO;
        shouldTryStealLock = NO;
        releaseIfSuccessful = NO;
	}
	return self;
}

+(NSString*) stringForOpType:(int)opType
{
    /*
     kOpTypeRegister = 0,
     kOpTypeUnregister,
     kOpTypeLock,
     kOpTypeUnlock,
     kOpTypeStealLock,
     kOpTypeGetCommonInfo,
     kOpTypeGetDetailedInfo,
     kOpTypeInitialize,
     kOpTypeGetConfiguration,
     kOpTypeConfigure,
     kOpTypeGetContentType,
     kOpTypeCapture,
     kOpTypeDownload,
     kOpTypeThriftyDownload,
     kOpTypeCancel,
     kOpTypeConnectSequence,
     kOpTypeCaptureSequence,
     kOpTypeDisconnectSequence,
     kOpTypeAll
     */
    switch (opType) {
        case kOpTypeRegister:
            return @"Register";
            break;
        case kOpTypeUnregister:
            return @"Unregister";
            break;
        case kOpTypeLock:
            return @"Lock";
            break;
        case kOpTypeUnlock:
            return @"Unlock";
            break;
        case kOpTypeStealLock:
            return @"Steal Lock";
            break;
        case kOpTypeGetCommonInfo:
            return @"Get Info";
            break;
        case kOpTypeGetDetailedInfo:
            return @"Get Detailed Info";
            break;
        case kOpTypeInitialize:
            return @"Initialize";
            break;
        case kOpTypeGetConfiguration:
            return @"Get Configuration";
            break;
        case kOpTypeConfigure:
            return @"Configure";
            break;
        case kOpTypeGetContentType:
            return @"Content Type";
            break;
        case kOpTypeCapture:
            return @"Capture";
            break;
        case kOpTypeDownload:
            return @"Download";
            break;
        case kOpTypeThriftyDownload:
            return @"Thrifty Download";
            break;
        case kOpTypeCancel:
            return @"Cancel";
            break;
        case kOpTypeConnectSequence:
            return @"Connect Sequence";
            break;
        case kOpTypeCaptureSequence:
            return @"Capture Sequence";
            break;
        case kOpTypeDisconnectSequence:
            return @"Disconnect Sequence";
            break;
        case kOpTypeAll:
            return @"All";
            break;

        default:
            return @"";
            break;
    }
}

#pragma mark - Property accessors
//-(void) setUri:(NSString *)newUri
//{
//    if (uri != newUri) {
//        [newUri retain];
//        [uri release];
//        uri = newUri;
//    }
//    
//    if (![uri hasPrefix:@"http://"]) {
//         //prepend this prefix if it doesn't exist.
//        uri = [[@"http://" stringByAppendingString:uri] retain];
//    }
//}
	

//TODO: Check for more HTTP error codes here.
-(BOOL) checkHTTPStatus:(ASIHTTPRequest*)request
{
	switch ([request responseStatusCode]) {
		case 404:
			[self sensorOperationFailed:request];
			return NO;
            operationInProgress = -1; //nothing's actually happening if the operation doesn't return valid data.
			break;
		default:
			return YES;
			break;
	}
	
}

#pragma mark - Convenience methods to combine multiple steps
-(BOOL) beginConnectSequence:(BOOL)tryStealLock withSenderTag:(int)senderTag
{
    if (self.sequenceInProgress) {
        //don't start another sequence if one is in progress
        return NO;
    }
  
    //kick off the connection sequence
    self.sequenceInProgress = YES;
    shouldTryStealLock = tryStealLock;
    [self beginRegisterClient:senderTag];
    return YES;
        
}

-(BOOL) beginCaptureSequence:(NSString *)sessionId captureType:(int)captureType withMaxSize:(float)maxSize withSenderTag:(int)senderTag
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
           withSenderTag:senderTag];
    
    return YES;
}

-(BOOL) beginDisconnectSequence:(NSString*)sessionId shouldReleaseIfSuccessful:(BOOL)shouldRelease withSenderTag:(int)senderTag
{
    if (self.sequenceInProgress) {
        //don't start another sequence if one is in progress
        return NO;
    }
    
    //kick off the disconnect sequence
    self.sequenceInProgress = YES;
    [self beginUnlock:self.currentSessionId withSenderTag:senderTag];
    return YES;
    
    releaseIfSuccessful = shouldRelease;
}

#pragma mark -
#pragma mark Methods to start various operations.

//Register
-(void) beginRegisterClient:(int)senderTag
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/register",self.uri]]];
	NSLog(@"Calling beginRegisterClient with URL %@",request.url);
	request.requestMethod = @"POST";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeRegister],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;
    
	[request setDidFinishSelector:@selector(registerClientCompleted:)];
	[networkQueue addOperation:request];
    
    operationInProgress = kOpTypeRegister;
}

-(void) beginUnregisterClient:(NSString*)sessionId withSenderTag:(int)senderTag
{	
	NSLog(@"Calling beginUnregisterClient");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/register/%@",self.uri, sessionId]]];
	request.requestMethod = @"DELETE";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeUnregister],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(unregisterClientCompleted:)];
	[networkQueue addOperation:request];
    operationInProgress = kOpTypeUnregister;

}


//Lock
-(void) beginLock:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginLock");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/lock/%@",self.uri, sessionId]]];
	request.requestMethod = @"POST";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeLock],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(lockCompleted:)];
	[networkQueue addOperation:request];
    operationInProgress = kOpTypeLock;

}

-(void) beginStealLock:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginStealLock");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/lock/%@",self.uri, sessionId]]];
	request.requestMethod = @"PUT";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeStealLock],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(stealLockCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeStealLock;
}

-(void) beginUnlock:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginUnlock");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/lock/%@",self.uri, sessionId]]];
	request.requestMethod = @"DELETE";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeUnlock],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(unlockCompleted:)];
	[networkQueue addOperation:request];
    operationInProgress = kOpTypeUnlock;
}


//Info
-(void) beginGetCommonInfo:(int)senderTag
{
	NSLog(@"Calling beginCommonInfo");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/info",self.uri]]];
	request.requestMethod = @"GET";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeGetCommonInfo],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(getCommonInfoCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeGetCommonInfo;
}

-(void) beginGetDetailedInfo:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginGetInfo");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/info/%@",self.uri, sessionId]]];
	request.requestMethod = @"GET";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeGetDetailedInfo],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(getInfoCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeGetDetailedInfo;
}

//Initialize
-(void) beginInitialize:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginInitialize");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/initialize/%@",self.uri, sessionId]]];
	request.requestMethod = @"POST";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeInitialize],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(initializeCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeInitialize;
}

//Configure
-(void) beginGetConfiguration:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginGetConfiguration");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/configure/%@",self.uri, sessionId]]];
	request.requestMethod = @"GET";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeConfigure],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(getConfigurationCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeGetConfiguration;
}

-(void) beginConfigure:(NSString*)sessionId withParameters:(NSDictionary*)params withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginConfigure");
	//build the body of the message from our stored parameters
	NSMutableString *messageBody = [NSMutableString stringWithString:@"<WsbdDictionary xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://itl.nist.gov/wsbd/L1\">"];
	if (params) {
        for(NSString* key in params)
        {
            [messageBody appendFormat:@"<item><key>%@</key><value xmlns:d3p1=\"http://www.w3.org/2001/XMLSchema\" i:type=\"d3p1:string\">%@</value></item>", key, [params objectForKey:key]];
        }
    }
	[messageBody appendString:@"</WsbdDictionary>"];

//    NSString *messageBody = @"<WsbdDictionary xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://itl.nist.gov/wsbd/L1\"><item><key>submodality</key><value xmlns:d3p1=\"http://www.w3.org/2001/XMLSchema\" i:type=\"d3p1:string\">rightThumb</value></item></WsbdDictionary>";
  
	//build the request
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/configure/%@",self.uri, sessionId]]];
	request.requestMethod = @"POST";
	NSData *tempData = [messageBody dataUsingEncoding:NSUTF8StringEncoding];
	[request addRequestHeader:@"Content-Type" value:@"application/xml; charset=utf-8"];
	[request appendPostData:tempData];
	
    NSLog(@"Raw configure headers are\n%@",request.requestHeaders);
	NSLog(@"Raw configure request is \n%@",[[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding]);
	
    
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeConfigure],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(configureCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeConfigure;
}


//Capture
-(void) beginCapture:(NSString*)sessionId withSenderTag:(int)senderTag
{

	NSLog(@"Calling beginCapture");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/capture/%@",self.uri, sessionId]]];
	request.requestMethod = @"POST";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeCapture],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(captureCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeCapture;
}

-(void) beginGetCaptureInfo:(NSString*)captureId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginGetCaptureInfo");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/capture/%@",self.uri, captureId]]];
	request.requestMethod = @"GET";
	[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeGetContentType],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(getCaptureInfoCompleted:)];
	[networkQueue addOperation:request];
    operationInProgress = kOpTypeGetContentType;
}



//Download
-(void) beginDownload:(NSString*)captureId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginDownload");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@",self.uri, captureId]]];
	request.requestMethod = @"GET";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeDownload],@"opType",[NSNumber numberWithInt:senderTag],@"tag",captureId,@"captureId",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(downloadCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeDownload;
}

-(void) beginDownload:(NSString*)captureId withMaxSize:(float)maxSize withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginDownload:withMaxSize");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@/%1.0f",self.uri, captureId, maxSize]]];
	request.requestMethod = @"GET";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeThriftyDownload],@"opType",[NSNumber numberWithInt:senderTag],@"tag",captureId,@"captureId",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

	[request setDidFinishSelector:@selector(downloadCompleted:)];
	[networkQueue addOperation:request];
	operationInProgress = kOpTypeThriftyDownload;
}

//Cancel
-(void) beginCancel:(NSString*)sessionId withSenderTag:(int)senderTag
{
	NSLog(@"Calling beginCancel");
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/cancel/%@",self.uri, sessionId]]];
	request.requestMethod = @"POST";
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kOpTypeCancel],@"opType",[NSNumber numberWithInt:senderTag],@"tag",nil]; //we'll use this to identify this operation.
	request.delegate = self;
    request.timeOutSeconds = self.networkTimeout;
    request.shouldContinueWhenAppEntersBackground = YES;

    [request setDidStartSelector:@selector(cancelRequestStarted:)];
    [request setDidReceiveDataSelector:@selector(cancelRequest:didReceiveData:)];
    [request setDidFailSelector:@selector(cancelRequestFailed:)];
	[request setDidFinishSelector:@selector(cancelCompleted:)];

	//Don't add this to the main network queue, as we don't want it stuck behind
    //the operation it's trying to cancel. Instead, start it this way,
    //which places it in a global NSOperationQueue that won't wait for the previous operation.
    [request startAsynchronous];
	operationPendingCancellation = operationInProgress; //store the operation we're cancelling.
    operationInProgress = kOpTypeCancel;
}

#pragma mark -
#pragma mark Async completion methods
//NOTE: These are largely repetitive at the moment, but may not be in the future.

//NOTE: This gets hit when the request fails, but also when the request contains an HTTP error code.
-(void) sensorOperationFailed:(ASIHTTPRequest*)request
{
	NSLog(@"Sensor operation failed with message %@", request.responseStatusMessage);
	[delegate sensorOperationDidFail:[[request.userInfo objectForKey:@"opType"] intValue] 
							fromLink:self 
						   withError:request.error];
    operationInProgress = -1;
}

//Register
-(void) registerClientCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed registration request successfully.");
	if (![self checkHTTPStatus:request])
		return;

	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorConnectSequenceCompletedFromLink:self withResult:nil];
        }
        return;
    }
 
    if (self.currentParseResult.status == StatusSuccess) {
        //set the registered convenience variable.
        self.registered = YES;
        //store the current session id.
        self.currentSessionId = self.currentParseResult.sessionId;
        //if this call is part of a sequence, call the next step.
        if (self.sequenceInProgress) {
            [self beginLock:self.currentSessionId withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }
    }
    else if (self.sequenceInProgress) {
        self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
        [delegate sensorConnectSequenceCompletedFromLink:self withResult:self.currentParseResult];
    }
    operationInProgress = -1;

}

-(void) unregisterClientCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed unregister request successfully.");
	if (![self checkHTTPStatus:request])
		return;

	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorDisconnectSequenceCompletedFromLink:self withResult:nil shouldReleaseIfSuccessful:releaseIfSuccessful];
        }
        return;

    }
    
    if (self.currentParseResult.status == StatusSuccess) {
        //set the registered convenience variable.
        self.registered = NO;

        //notify the delegate that we're no longer "connected and ready"
        //NOTE: This may also be done in the unlock method, but there's no guarantee that unlock will be called.
        [delegate sensorConnectionStatusChanged:NO fromLink:self];

        //clear the current session id.
        self.currentSessionId = nil;
    }

    //if this call is part of a sequence, notify our delegate that the sequence is complete.
    if (self.sequenceInProgress) {
        self.sequenceInProgress = NO;
        [delegate sensorDisconnectSequenceCompletedFromLink:self withResult:self.currentParseResult shouldReleaseIfSuccessful:releaseIfSuccessful];
        //reset the releaseIfSuccessful variable
        releaseIfSuccessful = NO;
    }
    operationInProgress = -1;


}

//Lock
-(void) lockCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed lock request successfully.");
	if (![self checkHTTPStatus:request])
		return;
	
    BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorConnectSequenceCompletedFromLink:self withResult:nil];
        }
        return;
    }

    if (self.currentParseResult.status == StatusSuccess) {
        //set the lock convenience variable.
        self.hasLock = YES;
        //if this call is part of a sequence, call the next step.
        if (self.sequenceInProgress) {
            [self beginInitialize:self.currentSessionId withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }
    }
    else if (self.sequenceInProgress && shouldTryStealLock)
    {
        //If the lock operation failed, but we've been told to try stealing the lock
        //if necessary, try to steal the lock.
        [self beginStealLock:self.currentSessionId withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
    }
    else if (self.sequenceInProgress) {
        self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
        [delegate sensorConnectSequenceCompletedFromLink:self withResult:self.currentParseResult];
    }
    operationInProgress = -1;

}

-(void) stealLockCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed steal lock request successfully.");

	if (![self checkHTTPStatus:request])
		return;
	
    BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorConnectSequenceCompletedFromLink:self withResult:nil];
        }
        return;

    }
    if (self.currentParseResult.status == StatusSuccess) {
        //set the lock convenience variable.
        self.hasLock = YES;
        //if this call is part of a sequence, call the next step.
        if (self.sequenceInProgress) {
            [self beginInitialize:self.currentSessionId withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }

    }
    else if (self.sequenceInProgress) {
        self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
        [delegate sensorConnectSequenceCompletedFromLink:self withResult:self.currentParseResult];
    }
    operationInProgress = -1;

}

-(void) unlockCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed unlock request successfully.");
	if (![self checkHTTPStatus:request])
		return;
	
    BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorDisconnectSequenceCompletedFromLink:self withResult:nil shouldReleaseIfSuccessful:releaseIfSuccessful];
        }
        return;

    }

    if (self.currentParseResult.status == StatusSuccess) {
        //set the lock convenience variable.
        self.hasLock = NO;
   
        //notify the delegate that we're no longer "connected and ready"
        //NOTE: This will also be called in the unregister method, as there's no guarantee that the unlock method will be called.
        [delegate sensorConnectionStatusChanged:NO fromLink:self];
         
        //if this call is part of a sequence, call the next step.
        if (self.sequenceInProgress) {
            [self beginUnregisterClient:self.currentSessionId withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }
    }

    else if (self.sequenceInProgress) {
        self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
        [delegate sensorDisconnectSequenceCompletedFromLink:self withResult:self.currentParseResult shouldReleaseIfSuccessful:releaseIfSuccessful];
    }
    operationInProgress = -1;

}

//Info
-(void) getCommonInfoCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed common info request successfully.");

	if (![self checkHTTPStatus:request])
		return;
	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        
    }
    operationInProgress = -1;

}

-(void) getInfoCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed detailed info request successfully.");

	if (![self checkHTTPStatus:request])
		return;
    
	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        
    }
    operationInProgress = -1;

}

//Initialize
-(void) initializeCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed initialization request successfully.");

	if (![self checkHTTPStatus:request])
		return;
    
	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorConnectSequenceCompletedFromLink:self withResult:nil];
        }
        return;

    }
    
    if (self.currentParseResult.status == StatusSuccess) {
        //set the lock convenience variable.
        self.initialized = YES;
        //notify the delegate that our status is now "connected and ready"
        [delegate sensorConnectionStatusChanged:YES fromLink:self];
    }
    
    //if this call is part of a sequence, notify our delegate that the sequence is complete.
    if (self.sequenceInProgress) {
        self.sequenceInProgress = NO;
        [delegate sensorConnectSequenceCompletedFromLink:self withResult:self.currentParseResult];
    }
    operationInProgress = -1;

}

//Configure
-(void) getConfigurationCompleted:(ASIHTTPRequest *)request
{
	NSLog(@"Completed get config request successfully.");

	if (![self checkHTTPStatus:request])
		return;
    
	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        
    }
    operationInProgress = -1;

}

-(void) configureCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed set config request successfully.");

	if (![self checkHTTPStatus:request])
		return;

    BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorCaptureSequenceCompletedFromLink:self withResults:nil withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }
        return;

    }

    if (self.currentParseResult.status == StatusSuccess) {
        //if this call is part of a sequence, call the next step.
        if (self.sequenceInProgress) {
            //begin capture
            [self beginCapture:self.currentSessionId withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }
    }
    else if (self.sequenceInProgress) {
        self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
        [delegate sensorCaptureSequenceCompletedFromLink:self withResults:nil withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]]; //pass nil as the results array because we didn't capture successfully.
    }
    operationInProgress = -1;

}

//Capture
-(void) captureCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed capture request successfully.");

	if (![self checkHTTPStatus:request])
		return;

    BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        if (self.sequenceInProgress) {
            self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
            [delegate sensorCaptureSequenceCompletedFromLink:self withResults:nil withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
        }
        return;

    }

    if (self.currentParseResult.status == StatusSuccess) {
        //if this call is part of a sequence, call the next step.
        if (self.sequenceInProgress) {
            //reset any existind download sequence variables.
            if (self.downloadSequenceResults) {
                [self.downloadSequenceResults removeAllObjects];
                self.downloadSequenceResults = nil;
            }

            //download each result.
            numCaptureIdsAwaitingDownload = [self.currentParseResult.captureIds count]; //since we're doing this asynchronously, we'll use this to know when we're done.
            for (NSString *capId in self.currentParseResult.captureIds) {
                [self beginDownload:capId withMaxSize:downloadMaxSize withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
            }
        }
    }
    else if (self.sequenceInProgress) {
        self.sequenceInProgress = NO; //stop the sequence, as we've got a failure.
        [delegate sensorCaptureSequenceCompletedFromLink:self withResults:nil withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]]; //pass nil as the results array because we didn't capture successfully.
    }
    operationInProgress = -1;

}

-(void) getCaptureInfoCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed get capture info request successfully.");

	if (![self checkHTTPStatus:request])
		return;
    
	BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        
    }
    operationInProgress = -1;

}


//Download
//this works for both beginDownload calls
-(void) downloadCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed download request successfully.");

	if (![self checkHTTPStatus:request])
		return;

    BOOL parseSuccess = [self parseResultData:responseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
    }
    else {
        [self sensorOperationFailed:request];
        //don't stop any sequence in progress here, as other download results may succeed.
        numCaptureIdsAwaitingDownload--;
        return;
    }

    float exponentialMultiplier = 0.5;
    NSString *currentId = [request.userInfo objectForKey:@"captureId"];
    if (!self.downloadSequenceResults) {
        self.downloadSequenceResults = [[NSMutableArray alloc] init];
    }

    if (self.currentParseResult.status == StatusSuccess) {
        //add the current download result to the list.
        [self.downloadSequenceResults addObject:self.currentParseResult];
        numCaptureIdsAwaitingDownload--;
        if (numCaptureIdsAwaitingDownload <= 0) {
            self.sequenceInProgress = NO;
            [delegate sensorCaptureSequenceCompletedFromLink:self withResults:self.downloadSequenceResults withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
            numCaptureIdsAwaitingDownload = 0;
        }
        //remove any retry counter attached to this request.
        if (currentId) {
            [downloadRetryCount removeObjectForKey:currentId];
        }
    }
    
    //Otherwise, if we're configured to retry automatically, do it.
    else if (self.currentParseResult.status == StatusPreparingDownload && self.shouldRetryDownloadIfPending)
    {
        //do an exponential back-off
        int currentCaptureRetryCount = [[downloadRetryCount objectForKey:currentId] intValue];
        //figure out the current retry interval
        NSTimeInterval currentCaptureInterval = (2^currentCaptureRetryCount - 1) * exponentialMultiplier;
        
        while (currentCaptureInterval < self.exponentialIntervalMax) {
            
            [NSThread sleepForTimeInterval:currentCaptureInterval]; //NOTE: we may need to run these *Completed methods on their own threads to avoid blocking the queue...?
            //put a new attempt at this download in the queue.
            [self beginDownload:currentId withMaxSize:downloadMaxSize withSenderTag:[[request.userInfo objectForKey:@"tag"] intValue]];
            
            //increase the retry count
            [downloadRetryCount setObject:[NSNumber numberWithInt:(currentCaptureRetryCount + 1)] forKey:currentId];
        }
    
    }
    
     operationInProgress = -1;

}

//Cancel
-(void) cancelCompleted:(ASIHTTPRequest*)request
{
	NSLog(@"Completed cancel request successfully.");

	if (![self checkHTTPStatus:request])
		return;

    BOOL parseSuccess = [self parseResultData:cancelResponseData];
	if (parseSuccess) {
        [delegate sensorOperationCompleted:[[request.userInfo objectForKey:@"opType"] intValue] 
                                  fromLink:self withResult:self.currentParseResult];
        
        //stop any sequence that was in progress.
        self.sequenceInProgress = NO;
        
        //Fire sensorOperationWasCancelled* in the delegate, and pass the opType
        //of the CANCELLED operation. 
        if (operationPendingCancellation >= 0) {
            [delegate sensorOperationWasCancelledByClient:operationPendingCancellation fromLink:self];
        }

    }
    else {
        [self sensorOperationFailed:request];
        
    }
    operationInProgress = -1;
    operationPendingCancellation = -1; //we've finished our attempt to cancel the specified operation.
}

#pragma mark -
#pragma mark Client-managed NETWORK OPERATION cancellation stuff.
//NOTE: This is NOT the WS-BD Cancel code. This is a failsafe to allow you to essentially
//kill everything in the network queue and start over.

//This will generally be called to kill long-running operations that don't hit the sensor;
//for example, download operations that are taking too long because of the chosen size or
//network constraints.
-(void) cancelAllOperations
{
	NSLog(@"Cancelling all queued operations.");
	[networkQueue cancelAllOperations];
	[delegate sensorOperationWasCancelledByClient:kOpTypeAll fromLink:self];
}

//This will generally be called after retrieving the matching request from the
//ASINetworkQueue (say, to match an existing download operation).
-(void) cancelOperation:(ASIHTTPRequest*)request
{
	NSLog(@"Cancelling operation %@",request);
	[request cancel];
	[delegate sensorOperationWasCancelledByClient:[[request.userInfo objectForKey:@"opType"] intValue] fromLink:self];
}

#pragma mark -
#pragma mark ASIHTTP delegate methods
-(BOOL) parseResultData:(NSMutableData*)parseableData
{
	//NSLog(@"Parsing result data after completed connection");
	
	//stop the network activity indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	//make sure we got XML rather than an XHTML-formatted error back
	NSString *checkReturnData = [[NSString alloc] initWithData:parseableData encoding:NSUTF8StringEncoding];
    
	if ([checkReturnData rangeOfString:@"<!DOCTYPE HTML" options:(NSCaseInsensitiveSearch)].location != NSNotFound ||
        [checkReturnData rangeOfString:@"<HTML" options:(NSCaseInsensitiveSearch)].location != NSNotFound
        ) {
		//then the call is returning some HTML, which pretty much means something's wrong.
		//For now, just log that error and return.
		NSLog(@"Got an unexpected (but non-connection-error-y) result: %@",checkReturnData);
		return NO;
	}
	
	//TESTING ONLY: Do a raw data dump.
	//NSLog(@"Raw data is:\n%@",[[[NSString alloc] initWithData:parseableData encoding:NSUTF8StringEncoding] autorelease] );
	
	//Parse the returned XML and place it in the parseResult object
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:parseableData];
	if (parser == nil) {
		return YES; //nothing to do.
	}
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldResolveExternalEntities:NO]; //just get the data.
	
	[parser parse];
    
    //TESTING ONLY: Print the status and message.
    NSLog(@"Resulting status is %@",[WSBDResult stringForStatusValue:self.currentParseResult.status]);
    NSLog(@"Resulting message is %@",self.currentParseResult.message);
        
    return YES;
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
	//NSLog(@"Network request started by queue.");
	[responseData setLength:0];
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

-(void) requestFailed:(ASIHTTPRequest*)request
{
	NSLog(@"Network request failed with message: %@",request.error);

	//stop the network activity indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	//notify whatever method was specified to receive notification that the connection is done.
	[self sensorOperationFailed:request];
    
    //if we were in a sequence, stop it.
    self.sequenceInProgress = NO;
	
}
 
//these are set manually for the cancel request.
- (void)cancelRequestStarted:(ASIHTTPRequest *)request
{
    //NSLog(@"Network request started by queue.");
    [cancelResponseData setLength:0];
}
 
-(void) cancelRequest:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    [cancelResponseData appendData:data];
}
 
-(void) cancelRequestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"Cancel request failed with message: %@",request.error);
    
    //stop the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //notify whatever method was specified to receive notification that the connection is done.
    [self sensorOperationFailed:request];
    
}


#pragma mark -
#pragma mark NSXMLParser delegate methods
#pragma mark NSXMLParserDelegate methods -- based on http://www.iphonedevsdk.com/forum/iphone-sdk-development/2841-resolved-how-call-soap-service-3.html
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.currentParseResult = nil;
	self.currentContainerArray = nil;
	self.currentContainerDictionary = nil;
	self.currentDictionaryKey = nil;
	self.currentDictionaryValue = nil;
	//	parentArray=[[NSMutableArray alloc] init];
//	[parentArray addObject:self.parseResult];
	self.currentElementName=@"";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	self.currentElementValue=@""; //clear this so that we can fill it with data from this element.
	self.currentElementName = elementName;
	
	if ([elementName localizedCaseInsensitiveCompare:@"WsbdResult"] == NSOrderedSame)
	{
		self.currentParseResult = [[WSBDResult alloc] init];
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"commonInfo"] == NSOrderedSame) {
		self.currentParseResult.infoCommon = [[NSMutableDictionary alloc] init];
		self.currentContainerDictionary = self.currentParseResult.infoCommon;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"detailedInfo"] == NSOrderedSame) {
		self.currentParseResult.infoDetailed = [[NSMutableDictionary alloc] init];
		self.currentContainerDictionary = self.currentParseResult.infoDetailed;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"configuration"] == NSOrderedSame) {
		self.currentParseResult.config = [[NSMutableDictionary alloc] init];
		self.currentContainerDictionary = self.currentParseResult.config;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"captureIds"] == NSOrderedSame) {
		self.currentParseResult.captureIds = [[NSMutableArray alloc] init];
		self.currentContainerArray = self.currentParseResult.captureIds;
	}
	
	//set up a new dictionary key
	else if ([elementName localizedCaseInsensitiveCompare:@"item"] == NSOrderedSame) {
		self.currentDictionaryKey = nil;
		self.currentDictionaryValue = nil;
	}
	
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	self.currentElementValue=string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	
	if ([elementName localizedCaseInsensitiveCompare:@"WsbdResult"] == NSOrderedSame)
	{
		//we're done. Nothing to do here.
	}
	
	else if ([elementName localizedCaseInsensitiveCompare:@"sensorData"] == NSOrderedSame) {
		//decode and store the results
		[Base64Coder initialize];
		self.currentParseResult.downloadData = [Base64Coder decode:self.currentElementValue];

	}
	//Dictionary elements
	else if ([elementName localizedCaseInsensitiveCompare:@"key"] == NSOrderedSame)
	{
		self.currentDictionaryKey = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"value"] == NSOrderedSame)
	{
		self.currentDictionaryValue = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"item"] == NSOrderedSame)
	{
		[self.currentContainerDictionary setObject:self.currentDictionaryValue forKey:self.currentDictionaryKey];
	}
	
	//array elements
	else if ([elementName localizedCaseInsensitiveCompare:@"element"] == NSOrderedSame)
	{
		[self.currentContainerArray addObject:self.currentElementValue];
	}
	
	else if ([elementName localizedCaseInsensitiveCompare:@"status"] == NSOrderedSame)
	{
		//create a StatusValue based on the string value of this element.
		//NOTE: Pretty clumsy.  Fix?
		StatusValue tempValue = -1;
		if ([self.currentElementValue localizedCaseInsensitiveCompare:@"Success"] == NSOrderedSame) {
			tempValue = StatusSuccess;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"Failure"] == NSOrderedSame) {
			tempValue = StatusFailure;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"InvalidId"] == NSOrderedSame) {
			tempValue = StatusInvalidId;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"Cancelled"] == NSOrderedSame) {
			tempValue = StatusCancelled;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"CancelledWithSensorFailure"] == NSOrderedSame) {
			tempValue = StatusCancelledWithSensorFailure;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"SensorFailure"] == NSOrderedSame) {
			tempValue = StatusSensorFailure;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"LockNotHeld"] == NSOrderedSame) {
			tempValue = StatusLockNotHeld;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"LockHeldByAnother"] == NSOrderedSame) {
			tempValue = StatusLockHeldByAnother;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"SensorNeedsInitialization"] == NSOrderedSame) {
			tempValue = StatusSensorNeedsInitialization;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"SensorNeedsConfiguration"] == NSOrderedSame) {
			tempValue = StatusSensorNeedsConfiguration;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"SensorBusy"] == NSOrderedSame) {
			tempValue = StatusSensorBusy;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"SensorTimeout"] == NSOrderedSame) {
			tempValue = StatusSensorTimeout;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"Unsupported"] == NSOrderedSame) {
			tempValue = StatusUnsupported;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"BadValue"] == NSOrderedSame) {
			tempValue = StatusBadValue;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"NoSuchParameter"] == NSOrderedSame) {
			tempValue = StatusNoSuchParameter;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"PreparingDownload"] == NSOrderedSame) {
			tempValue = StatusPreparingDownload;
		}
		self.currentParseResult.status = tempValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"sessionId"] == NSOrderedSame)
	{
		self.currentParseResult.sessionId = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"message"] == NSOrderedSame)
	{
		self.currentParseResult.message = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"contentType"] == NSOrderedSame)
	{
		self.currentParseResult.contentType = self.currentElementValue;
	}
	self.currentElementName=@"";
}

@end
