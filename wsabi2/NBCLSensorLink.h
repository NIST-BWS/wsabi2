//
//  NBCLSensorLink.h
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

#import <Foundation/Foundation.h>
#import "Base64Coder.h" //to decode the images
#import "WSModalityMap.h"
#import "WSBDResult.h"
#import "NBCLSensorLinkConstants.h"
#import "constants.h"

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@protocol NBCLSensorLinkDelegate <NSObject>

@optional
-(void) sensorOperationDidFail:(int)opType fromLink:(id)link withError:(NSError*)error;
-(void) sensorOperationWasCancelledByService:(int)opType fromLink:(id)link withResult:(WSBDResult*)result;
-(void) sensorOperationWasCancelledByClient:(int)opType fromLink:(id)link;
-(void) sensorOperationCompleted:(int)opType fromLink:(id)link withResult:(WSBDResult*)result;

-(void) sensorConnectionStatusChanged:(BOOL)connectedAndReady fromLink:(id)link;

//NOTE: The result object will be the result from the last performed step;
//so if the sequence succeeds, it'll be the last step in the sequence; otherwise
//it'll be the step that failed, so that the status will indicate what the problem was.
-(void) sensorConnectSequenceCompletedFromLink:(id)link withResult:(WSBDResult*)result;
//The array of results contains WSBDResults for each captureId.
//The tag is used to ID the UI element that made the request, so we can pass it the resulting data.
-(void) sensorCaptureSequenceCompletedFromLink:(id)link withResults:(NSMutableArray*)results withSenderTag:(int)tag;
-(void) sensorDisconnectSequenceCompletedFromLink:(id)link withResult:(WSBDResult*)result shouldReleaseIfSuccessful:(BOOL)shouldRelease;

@end


@interface NBCLSensorLink : NSObject <NSXMLParserDelegate> {

	//int maxImageSize;
	NSMutableArray *captureIds;
	
	SEL delegateSelector;
	
	//The data being processed for the current request. 
	NSMutableData *responseData;
    //The data being processed for any pending cancel request.
    NSMutableData *cancelResponseData;

    int operationInProgress;
    int operationPendingCancellation;

	ASINetworkQueue *networkQueue;
    	
    NSTimeInterval networkTimeout;
	    
    NSMutableDictionary *downloadRetryCount;
    NSTimeInterval exponentialIntervalMax;
        
    //instance-only variables (no properties attached)
    BOOL shouldTryStealLock;
    BOOL releaseIfSuccessful;
    float downloadMaxSize;
    int numCaptureIdsAwaitingDownload;
    	
}

+(NSString*) stringForOpType:(int)opType;

//-(void) sendRequest:(NSString*)requestString toRelativeAddress:(NSString*)relativeAddress withHTTPMethod:(NSString*)method;
-(BOOL) checkHTTPStatus:(ASIHTTPRequest*)request;

#pragma mark - Convenience methods to combine multiple steps
-(BOOL) beginConnectSequence:(BOOL)tryStealLock withSenderTag:(int)senderTag;
-(BOOL) beginCaptureSequence:(NSString*)sessionId captureType:(int)captureType withMaxSize:(float)maxSize withSenderTag:(int)senderTag;
-(BOOL) beginDisconnectSequence:(NSString*)sessionId shouldReleaseIfSuccessful:(BOOL)shouldRelease withSenderTag:(int)senderTag;

#pragma mark -
#pragma mark Async methods

//NOTE: The senderTag may be -1, in which case it is assumed that the caller isn't interested in tracking
//from where the call originated.

//Register
-(void) beginRegisterClient:(int)senderTag;
-(void) beginUnregisterClient:(NSString*)sessionId withSenderTag:(int)senderTag;

//Lock
-(void) beginLock:(NSString*)sessionId withSenderTag:(int)senderTag;
-(void) beginStealLock:(NSString*)sessionId withSenderTag:(int)senderTag;
-(void) beginUnlock:(NSString*)sessionId withSenderTag:(int)senderTag;

//Info
-(void) beginGetCommonInfo:(int)senderTag;
-(void) beginGetDetailedInfo:(NSString*)sessionId withSenderTag:(int)senderTag;

//Initialize
-(void) beginInitialize:(NSString*)sessionId withSenderTag:(int)senderTag;

//Configure
-(void) beginGetConfiguration:(NSString*)sessionId withSenderTag:(int)senderTag;
-(void) beginConfigure:(NSString*)sessionId withParameters:(NSDictionary*)params withSenderTag:(int)senderTag;

//Capture
-(void) beginCapture:(NSString*)sessionId withSenderTag:(int)senderTag;
-(void) beginGetCaptureInfo:(NSString*)captureId withSenderTag:(int)senderTag;

//Download
-(void) beginDownload:(NSString*)captureId withSenderTag:(int)senderTag;
-(void) beginDownload:(NSString*)captureId withMaxSize:(float)maxSize withSenderTag:(int)senderTag;

//Cancel
-(void) beginCancel:(NSString*)sessionId withSenderTag:(int)senderTag;

#pragma mark -
#pragma mark Async completion methods
-(void) sensorOperationFailed:(ASIHTTPRequest*)request;

//Register
-(void) registerClientCompleted:(ASIHTTPRequest*)request;
-(void) unregisterClientCompleted:(ASIHTTPRequest*)request;

//Lock
-(void) lockCompleted:(ASIHTTPRequest*)request;
-(void) stealLockCompleted:(ASIHTTPRequest*)request;
-(void) unlockCompleted:(ASIHTTPRequest*)request;

//Info
-(void) getCommonInfoCompleted:(ASIHTTPRequest*)request;
-(void) getInfoCompleted:(ASIHTTPRequest*)request;

//Initialize
-(void) initializeCompleted:(ASIHTTPRequest*)request;

//Configure
-(void) getConfigurationCompleted:(ASIHTTPRequest*)request;
-(void) configureCompleted:(ASIHTTPRequest*)request;

//Capture
-(void) captureCompleted:(ASIHTTPRequest*)request;
-(void) getCaptureInfoCompleted:(ASIHTTPRequest*)request;

//Download
//-(void) getDownloadInfoCompleted:(WSBDResult*)result;
-(void) downloadCompleted:(ASIHTTPRequest*)request; //this works for both beginDownload calls

//-(void) downloadMostRecentCaptureCompleted:(WSBDResult*)result; //convenience method

//Cancel
-(void) cancelCompleted:(ASIHTTPRequest*)request;

#pragma mark -
#pragma mark Client-managed cancellation operations
-(void) cancelAllOperations;
-(void) cancelOperation:(ASIHTTPRequest*)request;

#pragma mark -
#pragma mark ASIHTTPRequest-related methods
-(BOOL) parseResultData:(NSMutableData*)parseableData;
- (void)cancelRequestStarted:(ASIHTTPRequest *)request;
- (void)cancelRequest:(ASIHTTPRequest *)request didReceiveData:(NSData *)data;
- (void) cancelRequestFailed:(ASIHTTPRequest*)request;


#pragma mark -
#pragma mark Properties
@property (nonatomic) BOOL registered;
@property (nonatomic) BOOL hasLock;
@property (nonatomic) BOOL initialized;
@property (nonatomic) BOOL sequenceInProgress;
@property (nonatomic) BOOL shouldRetryDownloadIfPending;

@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *currentSessionId;
@property (nonatomic, strong) NSMutableArray *captureIds;
@property (nonatomic) NSTimeInterval networkTimeout;
@property (nonatomic) NSTimeInterval exponentialIntervalMax;

//WS-BD Variables
@property (nonatomic, strong) NSString *mainNamespace;
@property (nonatomic, strong) NSString *schemaInstanceNamespace;
@property (nonatomic, strong) NSString *schemaNamespace;

//NSXMLParser variables
@property (nonatomic, strong) WSBDResult *currentParseResult;
@property (nonatomic, strong) NSString *currentElementName;
@property (nonatomic, strong) NSString *currentElementValue;	
@property (nonatomic, strong) NSMutableArray *currentContainerArray;
@property (nonatomic, strong) NSMutableDictionary *currentContainerDictionary;
@property (nonatomic, strong) NSString *currentDictionaryKey;
@property (nonatomic, strong) NSString *currentDictionaryValue;
//@property (nonatomic) int maxImageSize;

@property (nonatomic, strong) NSDictionary *acceptableContentTypes;

@property (nonatomic, strong) NSMutableArray *downloadSequenceResults;

//Delegate
@property (nonatomic, unsafe_unretained) IBOutlet id<NBCLSensorLinkDelegate> delegate;

@end
