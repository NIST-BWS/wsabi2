// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "constants.h"
#import "NBCLDeviceLinkConstants.h"
#import "WSBDAFHTTPClient.h"
#import "WSBDParameter.h"
#import "WSBDResult.h"
#import "NBCLXMLMap.h"
#import "Base64Coder.h"
#import "NSURL+HTTP.h"

#import "WSDeviceLink.h"

#import "AFXMLRequestOperation.h"

@interface WSDeviceLink ()

@property (nonatomic, assign) NSInteger operationInProgress;
@property (nonatomic, assign) NSInteger operationPendingCancellation;

@property (nonatomic, assign) SensorSequenceType storedSequence;

//
// NSXMLParser Properties
//
@property (nonatomic, strong) WSBDResult *currentWSBDResult;
@property (nonatomic, strong) WSBDParameter *currentWSBDParameter;
@property (nonatomic, copy) NSString *currentElementName;
@property (nonatomic, copy) NSString *currentElementValue;
@property (nonatomic, strong) NSDictionary *currentElementAttributes;
@property (nonatomic, strong) NSMutableArray *currentContainerArray;
@property (nonatomic, strong) NSMutableDictionary *currentContainerDictionary;
@property (nonatomic, strong) id currentDictionaryKey;
@property (nonatomic, strong) id currentDictionaryValue;
@property (nonatomic, strong) NSXMLParser *XMLParser;

// Download properties
@property (nonatomic, strong) NSMutableArray *downloadSequenceResults;
@property (nonatomic, assign) NSInteger numCaptureIdsAwaitingDownload;
@property (nonatomic, assign) float downloadMaxSize;
@property (nonatomic, strong) NSMutableDictionary *downloadRetryCount;
@property (nonatomic, assign) NSTimeInterval exponentialIntervalMax;

@property (nonatomic, strong) WSBDAFHTTPClient* service;


//The configuration to be used in case we're running a capture sequence rather than
//individual operations (in which case we need a place to put the config while we're progressing).
@property (nonatomic, strong) NSMutableDictionary *pendingConfiguration;

@end

@implementation WSDeviceLink

- (id)initWithBaseURI:(NSString *)uri
{
    self = [super init];
    if (self == nil)
        return (nil);

    _baseURI = [NSURL HTTPURLWithString:uri];
    _service = [[WSBDAFHTTPClient alloc] initWithBaseURL:_baseURI];
    
    _operationInProgress = -1;
    _operationPendingCancellation = -1;
    
    _downloadRetryCount = [[NSMutableDictionary alloc] init];
    _exponentialIntervalMax = 30;
    
    _registered = NO;
    _hasLock = NO;
    _initialized = NO;
    _sequenceInProgress = kSensorSequenceNone;
    
    return (self);
}

- (void)setBaseURI:(NSURL *)baseURI
{
    _baseURI = baseURI;
    
    /* Reset service*/
    if ([self service] != nil) {
        [self cancelAllOperations];
        [self setService:[[WSBDAFHTTPClient alloc] initWithBaseURL:baseURI]];
    }
}

#pragma mark - Delegate Notification

- (void)notifyCompletedOperation:(NSInteger)operation withSourceObjectID:sourceObjectID
{
    if ([[self delegate] respondsToSelector:@selector(sensorOperationCompleted:fromLink:sourceObjectID:withResult:)]) {
        [[self delegate] sensorOperationCompleted:operation
                                         fromLink:self
                                   sourceObjectID:sourceObjectID
                                       withResult:self.currentWSBDResult];
    }
}

- (void)notifySequenceCompletedWithSourceObjectID:(NSURL *)sourceObjectID
{
    if ([[self delegate] respondsToSelector:@selector(connectSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
        [[self delegate] connectSequenceCompletedFromLink:self
                                               withResult:self.currentWSBDResult
                                           sourceObjectID:sourceObjectID];
    }
}

#pragma mark - Common Handling

- (void)cancelAllOperations
{
    if ([self service] != nil)
        [[self service] cancelAllHTTPOperationsWithMethod:nil path:nil];
    
    if ([[self delegate] respondsToSelector:@selector(sensorOperationWasCancelledByClient:fromLink:sourceObjectID:)])
        [[self delegate] sensorOperationWasCancelledByClient:kOpTypeAll fromLink:self sourceObjectID:nil];
}

- (BOOL)isSuccessValidWithResponse:(NSHTTPURLResponse *)response
{
    // Check HTTP return status
    if (([response statusCode] / 100) >= 3)
        return (NO);

    return (YES);
}

- (void)setSensorOperationFailedWithResponse:(NSHTTPURLResponse *)response userInfo:(NSDictionary *)userInfo
{
    NSLog(@"Sensor operation failed with message \"%@\" (HTTP %d)",
          [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode],
          response.statusCode);
    
    if ([[self delegate] respondsToSelector:@selector(sensorOperationDidFail:fromLink:sourceObjectID:withError:)]) {
        [[self delegate] sensorOperationDidFail:[userInfo[kDictKeyOperation] intValue]
                                       fromLink:self
                                 sourceObjectID:userInfo[kDictKeySourceID]
                                      withError:nil];
    }
    
    [self setOperationInProgress:-1];
}

- (void)failedToParseWithParser:(NSXMLParser *)parser userInfo:(NSDictionary *)userInfo
{
    NSLog(@"Failed to parse XML with error \"%@\"", parser.parserError.description);
    
    if ([[self delegate] respondsToSelector:@selector(sensorOperationDidFail:fromLink:sourceObjectID:withError:)]) {
        [[self delegate] sensorOperationDidFail:[userInfo[kDictKeyOperation] intValue]
                                       fromLink:self
                                 sourceObjectID:userInfo[kDictKeySourceID]
                                      withError:nil];
    }
    
    [self setOperationInProgress:-1];
}

- (BOOL)parseSuccessfulResponse:(NSHTTPURLResponse *)response withUserInfo:(NSDictionary *)userInfo responseObject:(id)responseObject
{
    // Check for error messages
    if ([self isSuccessValidWithResponse:response] == NO) {
        [self setSensorOperationFailedWithResponse:response userInfo:userInfo];
        return (NO);
    }
    
    // Parse the XML response from the service
    NSXMLParser *parser  = [[NSXMLParser alloc] initWithData:responseObject];
    [parser setDelegate:self];
    if ([parser parse] == NO) {
        [self setSensorOperationFailedWithResponse:response userInfo:userInfo];
        return (NO);
    }
    
    return (YES);
}

+ (NSString *)stringForSensorOperationType:(int)opType
{
    switch (opType) {
        case kOpTypeRegister:
            return (@"Register");
        case kOpTypeUnregister:
            return (@"Unregister");
        case kOpTypeLock:
            return (@"Lock");
        case kOpTypeUnlock:
            return (@"Unlock");
        case kOpTypeStealLock:
            return (@"Steal Lock");
        case kOpTypeGetCommonInfo:
            return (@"Get Info");
        case kOpTypeGetDetailedInfo:
            return (@"Get Detailed Info");
        case kOpTypeInitialize:
            return (@"Initialize");
        case kOpTypeGetConfiguration:
            return (@"Get Configuration");
        case kOpTypeConfigure:
            return (@"Configure");
        case kOpTypeGetContentType:
            return (@"Content Type");
        case kOpTypeCapture:
            return (@"Capture");
        case kOpTypeDownload:
            return (@"Download");
        case kOpTypeThriftyDownload:
            return (@"Thrifty Download");
        case kOpTypeCancel:
            return (@"Cancel");
        case kOpTypeConnectSequence:
            return (@"Connect Sequence");
        case kOpTypeCaptureSequence:
            return (@"Capture Sequence");
        case kOpTypeDisconnectSequence:
            return (@"Disconnect Sequence");
        case kOpTypeAll:
            return (@"All");
        default:
            return (@"<UNKNOWN>");
    }
}

#pragma mark - NSXMLParser Delegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.currentWSBDResult = nil;
	self.currentContainerArray = nil;
	self.currentContainerDictionary = nil;
	self.currentDictionaryKey = nil;
	self.currentDictionaryValue = nil;
    self.currentWSBDParameter = nil;
    
	self.currentElementName=@"";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	self.currentElementValue=@""; //clear this so that we can fill it with data from this element.
	self.currentElementName = elementName;
    self.currentElementAttributes = attributeDict;
	
	if ([elementName localizedCaseInsensitiveCompare:@"result"] == NSOrderedSame)
	{
		self.currentWSBDResult = [[WSBDResult alloc] init];
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"metadata"] == NSOrderedSame) {
		self.currentWSBDResult.metadata = [[NSMutableDictionary alloc] init];
		self.currentContainerDictionary = self.currentWSBDResult.metadata;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"configuration"] == NSOrderedSame) {
		self.currentWSBDResult.config = [[NSMutableDictionary alloc] init];
		self.currentContainerDictionary = self.currentWSBDResult.config;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"captureIds"] == NSOrderedSame) {
		self.currentWSBDResult.captureIds = [[NSMutableArray alloc] init];
		self.currentContainerArray = self.currentWSBDResult.captureIds;
	}
	
	//set up a new dictionary item, and flush any existing related placeholders
	else if ([elementName localizedCaseInsensitiveCompare:@"item"] == NSOrderedSame) {
		self.currentDictionaryKey = nil;
		self.currentDictionaryValue = nil;
        self.currentWSBDParameter = nil;
	}
    
	else if ([elementName localizedCaseInsensitiveCompare:@"value"] == NSOrderedSame)
	{
        //If we hit a Parameter-typed element, this is a WSBDParameter
        if ([[attributeDict objectForKey:@"i:type"] localizedCaseInsensitiveCompare:@"Parameter"] == NSOrderedSame) {
            self.currentWSBDParameter = [[WSBDParameter alloc] init];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	self.currentElementValue=string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	
	if ([elementName localizedCaseInsensitiveCompare:@"result"] == NSOrderedSame)
	{
		//we're done. Nothing to do here.
	}
	
	else if ([elementName localizedCaseInsensitiveCompare:@"sensorData"] == NSOrderedSame) {
		//decode and store the results
		[Base64Coder initialize];
		self.currentWSBDResult.downloadData = [Base64Coder decode:self.currentElementValue];
        
	}
	//Dictionary elements
	else if ([elementName localizedCaseInsensitiveCompare:@"key"] == NSOrderedSame)
	{
		self.currentDictionaryKey = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"value"] == NSOrderedSame)
	{
        
        if (self.currentWSBDResult.metadata && self.currentWSBDParameter) {
            
            //            NSLog(@"About to store %@ in the metadata dict under key %@",[self.currentWSBDParameter debugDescription], self.currentDictionaryKey);
            
            //store that value in the dictionary
            [self.currentWSBDResult.metadata setObject:self.currentWSBDParameter forKey:self.currentDictionaryKey];
            self.currentDictionaryValue = self.currentWSBDParameter;
            
            //We also need to clear the current WSBDParameter value here.
            self.currentWSBDParameter = nil;
        }
        else {
            //treat this as a normal element
            self.currentDictionaryValue = self.currentElementValue;
        }
        
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
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"initializationNeeded"] == NSOrderedSame) {
			tempValue = StatusSensorNeedsInitialization;
		}
		else if ([self.currentElementValue localizedCaseInsensitiveCompare:@"configurationNeeded"] == NSOrderedSame) {
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
		self.currentWSBDResult.status = tempValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"sessionId"] == NSOrderedSame)
	{
		self.currentWSBDResult.sessionId = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"message"] == NSOrderedSame)
	{
		self.currentWSBDResult.message = self.currentElementValue;
	}
	else if ([elementName localizedCaseInsensitiveCompare:@"contentType"] == NSOrderedSame)
	{
		self.currentWSBDResult.contentType = self.currentElementValue;
	}
    
    /****Parameter values****/
    else if (self.currentWSBDParameter && [elementName localizedCaseInsensitiveCompare:@"name"] == NSOrderedSame)
    {
        self.currentWSBDParameter.name = self.currentElementValue;
    }
    else if (self.currentWSBDParameter && [elementName localizedCaseInsensitiveCompare:@"type"] == NSOrderedSame)
    {
        self.currentWSBDParameter.type = self.currentElementValue;
    }
    else if (self.currentWSBDParameter && [elementName localizedCaseInsensitiveCompare:@"readOnly"] == NSOrderedSame)
    {
        self.currentWSBDParameter.readOnly = ([self.currentElementValue localizedCaseInsensitiveCompare:@"true"] == NSOrderedSame);
    }
    
    else if (self.currentWSBDParameter && [elementName localizedCaseInsensitiveCompare:@"defaultValue"] == NSOrderedSame)
    {
        NSString *typeString = nil;
        for (NSString *key in self.currentElementAttributes.allKeys) {
            if ([key localizedCaseInsensitiveCompare:@"i:type"] == NSOrderedSame) {
                typeString = [self.currentElementAttributes objectForKey:key];
            }
        }
        
        //Get the converted object and store it.
        self.currentWSBDParameter.defaultValue = [NBCLXMLMap objcObjectForXML:self.currentElementValue ofType:typeString];
        NSLog(@"Parameter %@ has defaultValue %@",self.currentWSBDParameter.name, self.currentWSBDParameter.defaultValue);
    }
    
    else if (self.currentWSBDParameter && [elementName localizedCaseInsensitiveCompare:@"allowedValue"] == NSOrderedSame)
    {
        NSString *typeString = nil;
        for (NSString *key in self.currentElementAttributes.allKeys) {
            if ([key localizedCaseInsensitiveCompare:@"i:type"] == NSOrderedSame) {
                typeString = [self.currentElementAttributes objectForKey:key];
            }
        }
        
        //if necessary, create the array we're about to add to.
        if (!self.currentWSBDParameter.allowedValues) {
            self.currentWSBDParameter.allowedValues = [[NSMutableArray alloc] init];
        }
        //Get the converted object and store it.
        [self.currentWSBDParameter.allowedValues addObject:[NBCLXMLMap objcObjectForXML:self.currentElementValue ofType:typeString]];
        
    }
    
	self.currentElementName=@"";
    self.currentElementAttributes = nil;
}

#pragma mark - Network Operations

#pragma mark - Generic

- (NSString *)pathForOperation:(SensorOperationType)operation withSessionID:(NSString *)sessionID
{
    switch (operation) {
        case kOpTypeRegister:
            return (@"register");
        case kOpTypeUnregister:
            return ([NSString stringWithFormat:@"register/%@", sessionID]);
        case kOpTypeLock:
            return ([NSString stringWithFormat:@"lock/%@", sessionID]);
        case kOpTypeUnlock:
            return ([NSString stringWithFormat:@"lock/%@", sessionID]);
        case kOpTypeStealLock:
            return ([NSString stringWithFormat:@"lock/%@", sessionID]);
        case kOpTypeGetCommonInfo:
            return ([NSString stringWithFormat:@"info"]);
        case kOpTypeInitialize:
            return ([NSString stringWithFormat:@"initialize/%@", sessionID]);
        case kOpTypeGetConfiguration:
            return ([NSString stringWithFormat:@"configure/%@", sessionID]);
        case kOpTypeConfigure:
            return ([NSString stringWithFormat:@"configure/%@", sessionID]);
        case kOpTypeGetContentType:
            return ([NSString stringWithFormat:@"download/%@", sessionID]);
        case kOpTypeCapture:
            return ([NSString stringWithFormat:@"capture/%@", sessionID]);
        case kOpTypeThriftyDownload:
            return ([NSString stringWithFormat:@"download/%@/%1.0f", sessionID, self.downloadMaxSize]);
        case kOpTypeDownload:
            return ([NSString stringWithFormat:@"download/%@", sessionID]);
        case kOpTypeCancel:
            return ([NSString stringWithFormat:@"cancel/%@", sessionID]);
        default:
            return (nil);
    }
}

- (NSMutableURLRequest *)networkOperation:(SensorOperationType)operation
                               withMethod:(NSString *)method
                           sourceObjectID:(NSURL *)sourceObjectID
                                sessionID:(NSString *)sessionID
                               parameters:(NSDictionary *)parameters
{
    [self setOperationInProgress:operation];
    NSLog(@"%@", [self pathForOperation:operation withSessionID:sessionID]);
    return ([[self service] requestWithMethod:method
                                         path:[self pathForOperation:operation withSessionID:sessionID]
                                   parameters:parameters]);
}

- (void)enqueueNetworkOperation:(SensorOperationType)operation
                    withRequest:(NSURLRequest *)request
                 sourceObjectID:(NSURL *)sourceObjectID
                      sessionID:(NSString *)sessionID
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser))success
                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser))failure
{
    NSDictionary *userInfo;
    if (sourceObjectID != nil)
        userInfo = @{kDictKeyOperation : [NSNumber numberWithInt:operation], kDictKeySourceID : sourceObjectID};
    else
        userInfo = @{kDictKeyOperation : [NSNumber numberWithInt:operation]};
    
    void (^defaultSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
        // Check status code, etc.
        if ([self isSuccessValidWithResponse:response] == NO) {
            [self setSensorOperationFailedWithResponse:response userInfo:userInfo];
            return;
        }
        
        // Parse XML response
        [parser setDelegate:self];
        if ([parser parse] == NO) {
            [self failedToParseWithParser:parser userInfo:userInfo];
            return;
        }
        
        // Notify delegate
        [self notifyCompletedOperation:[userInfo[kDictKeyOperation] intValue] withSourceObjectID:userInfo[kDictKeySourceID]];
        
        // Call user-defined success block
        if (success != NULL)
            success(request, response, parser);
        
        self.operationInProgress = -1;
    };
    
    void (^defaultFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser) {
        [self setSensorOperationFailedWithResponse:response userInfo:userInfo];
        
        // Call user-defined failure block
        if (failure != NULL)
            failure(request, response, error, parser);
    };
    
    [self.service enqueueHTTPRequestOperation:
     [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request
                                                         success:defaultSuccessBlock
                                                         failure:defaultFailureBlock
      ]
     ];
}

- (void)enqueueNetworkOperation:(SensorOperationType)operation
                     withMethod:(NSString *)method
                 sourceObjectID:(NSURL *)sourceObjectID
                      sessionID:(NSString *)sessionID
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser))success
                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser))failure
{
    [self enqueueNetworkOperation:operation withRequest:[self networkOperation:operation
                                                                    withMethod:method
                                                                sourceObjectID:sourceObjectID
                                                                     sessionID:sessionID
                                                                    parameters:parameters]
                   sourceObjectID:sourceObjectID
                        sessionID:sessionID
                       parameters:parameters
                          success:success
                          failure:failure
     ];
}

#pragma mark Setup and Cleanup

- (void)registerClient:(NSURL *)sourceObjectID
{
    [self enqueueNetworkOperation:kOpTypeRegister
                       withMethod:kBCLMethodPOST
                   sourceObjectID:sourceObjectID
                        sessionID:nil
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //set the registered convenience variable.
                                  _registered = YES;
                                  //store the current session id.
                                  self.currentSessionId = self.currentWSBDResult.sessionId;
                                  //if this call is part of a sequence, call the next step.
                                  if (self.sequenceInProgress)
                                      [self lock:self.currentSessionId sourceObjectID:sourceObjectID];
                              } else if (self.sequenceInProgress) {
                                  _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                  [self notifySequenceCompletedWithSourceObjectID:sourceObjectID];
                              }
                          }
                          failure:NULL
     ];
}

- (void)unregisterClient:(NSString *)sessionId sourceObjectId:(NSURL *)sourceObjectID
{
    [self enqueueNetworkOperation:kOpTypeUnregister
                       withMethod:kBCLMethodDELETE
                   sourceObjectID:sourceObjectID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //set the registered convenience variable.
                                  _registered = NO;
                                  
                                  //notify the delegate that we're no longer "connected and ready"
                                  if ([[self delegate] respondsToSelector:@selector(sensorConnectionStatusChanged:fromLink:sourceObjectID:)]) {
                                      [[self delegate] sensorConnectionStatusChanged:NO
                                                                            fromLink:self
                                                                      sourceObjectID:sourceObjectID
                                       ];
                                  }
                                  
                                  //clear the current session id.
                                  self.currentSessionId = nil;
                              }
                              
                              //if this call is part of a sequence, notify our delegate that the sequence is complete.
                              if (self.sequenceInProgress) {
                                  _sequenceInProgress = kSensorSequenceNone;
                                  if ([[self delegate] respondsToSelector:@selector(disconnectSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                      [[self delegate] disconnectSequenceCompletedFromLink:self
                                                                                withResult:self.currentWSBDResult
                                                                            sourceObjectID:sourceObjectID];
                                  }
                              }
                          }
                          failure:NULL
     ];
}

- (void)initialize:(NSString *)sessionId sourceObjectId:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeInitialize
                       withMethod:kBCLMethodPOST
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //set the initialization convenience variable.
                                  _initialized = YES;
                                  //notify the delegate that our status is now "connected and ready"
                                  if ([[self delegate] respondsToSelector:@selector(sensorConnectionStatusChanged:fromLink:sourceObjectID:)]) {
                                      [[self delegate] sensorConnectionStatusChanged:YES fromLink:self sourceObjectID:sourceID];
                                  }
                                  
                                  //If this is a recovery sequence, use the stored sequence to determine
                                  //what to do next. Otherwise, use the main sequence.
                                  SensorSequenceType seq = self.sequenceInProgress;
                                  if (self.sequenceInProgress == kSensorSequenceRecovery) {
                                      seq = self.storedSequence;
                                  }
                                  
                                  if (seq == kSensorSequenceFull ||
                                      seq == kSensorSequenceConfigure) {
                                      //If we're not done, continue to configuring the sensor.
                                      [self setConfiguration:self.currentSessionId withParameters:self.pendingConfiguration sourceObjectID:sourceID];
                                  }
                                  else if (seq != kSensorSequenceNone)
                                  {
                                      //otherwise, we're done. Unlock.
                                      [self unlock:self.currentSessionId sourceObjectID:sourceID];
                                  }
                              }
                              else if (self.sequenceInProgress) {
                                  if(self.sequenceInProgress != kSensorSequenceRecovery)
                                  {
                                      //If we haven't already tried it, attempt to recover
                                      [self attemptWSBDSequenceRecovery:sourceID];
                                  }
                                  else {
                                      //We've already tried to recover; give up.
                                      //Release the lock.
                                      [self unlock:self.currentSessionId
                                    sourceObjectID:sourceID];
                                      
                                      if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                                  fromLink:self
                                                                withResult:self.currentWSBDResult
                                                            sourceObjectID:sourceID];
                                      }
                                      _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                      
                                  }
                              }
                          }
                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser) {
                              [self unlock:sessionId sourceObjectID:sourceID];
                          }
     ];
}

- (void)cancel:(NSString *)sessionId sourceObjectID:(NSURL *)sourceObjectID
{
    [self enqueueNetworkOperation:kOpTypeCancel
                       withMethod:kBCLMethodPOST
                   sourceObjectID:sourceObjectID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              //cancel any sequence that was in progress.
                              if (self.sequenceInProgress) {
                                  if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)]) {
                                      [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                              fromLink:self
                                                            withResult:self.currentWSBDResult
                                                        sourceObjectID:sourceObjectID
                                       ];
                                  }
                                  
                                  _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                              }
                              
                              //Fire sensorOperationWasCancelled* in the delegate, and pass the opType
                              //of the *cancelled* operation.
                              if (self.operationPendingCancellation >= 0) {
                                  if ([[self delegate] respondsToSelector:@selector(sensorOperationWasCancelledByClient:fromLink:sourceObjectID:)]) {
                                      [[self delegate] sensorOperationWasCancelledByClient:self.operationPendingCancellation fromLink:self sourceObjectID:sourceObjectID];
                                  }
                              }
                              
                              self.operationPendingCancellation = -1;
                          }
                          failure:NULL
     ];
}

#pragma mark Configuration

- (void)setConfiguration:(NSString *)sessionId withParameters:(NSDictionary *)params sourceObjectID:(NSURL *)sourceID
{
    NSMutableURLRequest *configureRequest = [self networkOperation:kOpTypeConfigure withMethod:kBCLMethodPOST sourceObjectID:sourceID sessionID:sessionId parameters:nil];
    NSMutableString *messageBody = [NSMutableString stringWithFormat:@"<configuration %@ %@ %@>", kBCLSchemaInstanceNamespace, kBCLSchemaNamespace, kBCLWSBDNamespace];
	if (params)
        for(NSString* key in params)
            [messageBody appendFormat:@"<item><key>%@</key>%@</item>", key, [NBCLXMLMap xmlElementForObject:[params objectForKey:key] withElementName:@"value"]];
    [messageBody appendString:@"</configuration>"];
    [configureRequest setHTTPBody:[messageBody dataUsingEncoding:NSUTF8StringEncoding]];
    [configureRequest addValue:kBCLHTTPHeaderValueXMLContentType forHTTPHeaderField:kBCLHTTPHeaderKeyContentType];
    
    [self enqueueNetworkOperation:kOpTypeConfigure
                      withRequest:configureRequest
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //If this is a recovery sequence, use the stored sequence to determine
                                  //what to do next. Otherwise, use the main sequence.
                                  SensorSequenceType seq = self.sequenceInProgress;
                                  if (self.sequenceInProgress == kSensorSequenceRecovery) {
                                      seq = self.storedSequence;
                                  }
                                  
                                  //if this call is part of a sequence, call the next step.
                                  if (seq == kSensorSequenceCaptureDownload ||
                                      seq == kSensorSequenceConfigCaptureDownload ||
                                      seq == kSensorSequenceFull
                                      )
                                  {
                                      //begin capture
                                      [self capture:self.currentSessionId sourceObjectID:sourceID];
                                  }
                                  else if (seq == kSensorSequenceConfigure ||
                                           seq == kSensorSequenceConnectConfigure)
                                  {
                                      //First, return the lock
                                      [self unlock:self.currentSessionId sourceObjectID:sourceID];
                                      
                                      //In this case, this is the last step, so unset the sequence variable and
                                      //notify our delegate.
                                      _sequenceInProgress = kSensorSequenceNone;
                                      if ([[self delegate] respondsToSelector:@selector(configureSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] configureSequenceCompletedFromLink:self
                                                                                   withResult:self.currentWSBDResult
                                                                               sourceObjectID:sourceID];
                                      }
                                  }
                                  
                              }
                              else if (self.sequenceInProgress) {
                                  if(self.sequenceInProgress != kSensorSequenceRecovery)
                                  {
                                      //If we haven't already tried it, attempt to recover
                                      [self attemptWSBDSequenceRecovery:sourceID];
                                  }
                                  else {
                                      if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                                  fromLink:self
                                                                withResult:self.currentWSBDResult
                                                            sourceObjectID:sourceID
                                           ];
                                      }
                                      _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                      
                                      //Try to force an unlock
                                      [self unlock:self.currentSessionId sourceObjectID:sourceID];
                                      
                                  }
                              }
                          }
                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser) {
                              [self unlock:sessionId sourceObjectID:sourceID];
                          }
     ];
}

- (void)getConfiguration:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeGetConfiguration
                       withMethod:kBCLMethodGET
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:NULL
                          failure:NULL
     ];
}

- (void)getServiceInfo:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeGetCommonInfo
                       withMethod:kBCLMethodGET
                   sourceObjectID:sourceID
                        sessionID:nil
                       parameters:nil
                          success:NULL
                          failure:NULL
     ];
}


#pragma mark Locking and Unlocking

- (void)lock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeLock
                       withMethod:kBCLMethodPOST
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //set the lock convenience variable.
                                  _hasLock = YES;
                                  
                                  //If this is a recovery sequence, use the stored sequence to determine
                                  //what to do next. Otherwise, use the main sequence.
                                  SensorSequenceType seq = self.sequenceInProgress;
                                  if (self.sequenceInProgress == kSensorSequenceRecovery) {
                                      seq = self.storedSequence;
                                  }
                                  //if this call is part of a sequence, call the next step.
                                  if (seq == kSensorSequenceConnect ||
                                      seq == kSensorSequenceConnectConfigure ||
                                      seq == kSensorSequenceFull)
                                  {
                                      [self initialize:self.currentSessionId sourceObjectId:sourceID];
                                  }
                                  else if (seq == kSensorSequenceConfigure ||
                                           seq == kSensorSequenceConfigCaptureDownload) {
                                      
                                      [self setConfiguration:self.currentSessionId withParameters:self.pendingConfiguration sourceObjectID:sourceID];
                                  }
                                  else if (seq == kSensorSequenceCaptureDownload)
                                  {
                                      [self capture:self.currentSessionId sourceObjectID:sourceID];
                                  }
                              }
                              else if (self.sequenceInProgress) {
                                  
                                  if(self.sequenceInProgress != kSensorSequenceRecovery)
                                  {
                                      //If we haven't already tried it, attempt to recover
                                      [self attemptWSBDSequenceRecovery:sourceID];
                                  }
                                  else {
                                      //We've already tried to recover; give up.
                                      _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                      
                                      if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)])
                                      {
                                          [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                                  fromLink:self
                                                                withResult:self.currentWSBDResult
                                                            sourceObjectID:sourceID
                                           ];
                                      }
                                  }
                              }
                          }
                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser) {
                              [self unlock:sessionId sourceObjectID:sourceID];
                          }
     ];
}

- (void)stealLock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeStealLock
                       withMethod:kBCLMethodPUT
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //set the lock convenience variable.
                                  _hasLock = YES;
                                  //if this call is part of a sequence, call the next step.
                                  if (self.sequenceInProgress == kSensorSequenceConnect) {
                                      [self initialize:self.currentSessionId sourceObjectId:sourceID];
                                  }
                                  else if (self.sequenceInProgress == kSensorSequenceConfigure ||
                                           self.sequenceInProgress == kSensorSequenceConfigCaptureDownload) {
                                      
                                      [self setConfiguration:self.currentSessionId withParameters:self.pendingConfiguration
                                              sourceObjectID:sourceID];
                                  }
                                  else if (self.sequenceInProgress == kSensorSequenceCaptureDownload)
                                  {
                                      [self capture:self.currentSessionId sourceObjectID:sourceID];
                                  }
                                  
                              }
                              else if (self.sequenceInProgress) {
                                  if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)])
                                  {
                                      [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                              fromLink:self
                                                            withResult:self.currentWSBDResult
                                                        sourceObjectID:sourceID
                                       ];
                                  }
                                  _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                              }
                          }
                          failure:NULL
     ];
}

- (void)unlock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeUnlock
                       withMethod:kBCLMethodDELETE
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //set the lock convenience variable.
                                  _hasLock = NO;
                                  
                                  //notify the delegate that we're no longer "connected and ready"
                                  if ([[self delegate] respondsToSelector:@selector(sensorConnectionStatusChanged:fromLink:sourceObjectID:)]) {
                                      [[self delegate] sensorConnectionStatusChanged:NO fromLink:self sourceObjectID:sourceID];
                                  }
                                  
                                  //First, handle recovery mode.
                                  //If we've completed one of several sequences in recovery mode,
                                  //restore the stored sequence and respond as if we'd never attempted
                                  //a recovery.
                                  if (self.sequenceInProgress == kSensorSequenceRecovery)
                                  {
                                      _sequenceInProgress = self.storedSequence;
                                      
                                      //clear the stored sequence.
                                      self.storedSequence = kSensorSequenceNone;
                                  }
                                  
                                  //if this call is part of a sequence, call the next step.
                                  if (self.sequenceInProgress == kSensorSequenceDisconnect) {
                                      [self unregisterClient:self.currentSessionId sourceObjectId:sourceID];
                                  }
                                  
                                  /** MOST SEQUENCES END HERE **/
                                  else if(self.sequenceInProgress == kSensorSequenceConnect)
                                  {
                                      //this is the end of the sequence.
                                      _sequenceInProgress = kSensorSequenceNone;
                                      if ([[self delegate] respondsToSelector:@selector(connectSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] connectSequenceCompletedFromLink:self
                                                                                 withResult:self.currentWSBDResult
                                                                             sourceObjectID:sourceID];
                                      }
                                  }
                                  else if(self.sequenceInProgress == kSensorSequenceConfigure)
                                  {
                                      //this is the end of the sequence.
                                      _sequenceInProgress = kSensorSequenceNone;
                                      if ([[self delegate] respondsToSelector:@selector(configureSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] configureSequenceCompletedFromLink:self
                                                                                   withResult:self.currentWSBDResult
                                                                               sourceObjectID:sourceID];
                                      }
                                  }
                                  else if(self.sequenceInProgress == kSensorSequenceConnectConfigure)
                                  {
                                      //this is the end of the sequence.
                                      _sequenceInProgress = kSensorSequenceNone;
                                      if ([[self delegate] respondsToSelector:@selector(connectConfigureSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] connectConfigureSequenceCompletedFromLink:self
                                                                                          withResult:self.currentWSBDResult
                                                                                      sourceObjectID:sourceID];
                                      }
                                  }
                                  
                                  
                              }
                              
                              else if (self.sequenceInProgress) {
                                  if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)]) {
                                      [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                              fromLink:self
                                                            withResult:self.currentWSBDResult
                                                        sourceObjectID:sourceID
                                       ];
                                  }
                                  _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                              }
                          }
                          failure:NULL
     ];
}

#pragma mark Capture and Download

- (void)capture:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeCapture
                       withMethod:kBCLMethodPOST
                   sourceObjectID:sourceID
                        sessionID:sessionId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if (self.currentWSBDResult.status == StatusSuccess) {
                                  //If this is a recovery sequence, use the stored sequence to determine
                                  //what to do next. Otherwise, use the main sequence.
                                  SensorSequenceType seq = self.sequenceInProgress;
                                  if (self.sequenceInProgress == kSensorSequenceRecovery) {
                                      seq = self.storedSequence;
                                  }
                                  
                                  //if this call is part of a sequence, call the next step.
                                  if (seq) {
                                      //First, return the lock
                                      [self unlock:self.currentSessionId sourceObjectID:sourceID];
                                      //reset any existing download sequence variables.
                                      if (self.downloadSequenceResults) {
                                          [self.downloadSequenceResults removeAllObjects];
                                          self.downloadSequenceResults = nil;
                                      }
                                      
                                      //download each result.
                                      self.numCaptureIdsAwaitingDownload = [self.currentWSBDResult.captureIds count]; //since we're doing this asynchronously, we'll use this to know when we're done.
                                      for (NSString *capId in self.currentWSBDResult.captureIds)
                                          [self download:capId withMaxSize:self.downloadMaxSize sourceObjectID:sourceID];
                                  }
                              }
                              else if (self.sequenceInProgress) {
                                  if(self.sequenceInProgress != kSensorSequenceRecovery)
                                  {
                                      //If we haven't already tried it, attempt to recover
                                      [self attemptWSBDSequenceRecovery:sourceID];
                                  }
                                  else {
                                      if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)]) {
                                          [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                                  fromLink:self
                                                                withResult:self.currentWSBDResult
                                                            sourceObjectID:sourceID
                                           ];
                                      }
                                      _sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                      //Try to force an unlock
                                      [self unlock:self.currentSessionId sourceObjectID:sourceID];
                                  }
                              }
                          }
                          failure:NULL
     ];
}

- (void)getDownloadInfo:(NSString *)captureId sourceObjectID:(NSURL *)sourceObjectID
{
    [self enqueueNetworkOperation:kOpTypeGetContentType
                       withMethod:kBCLMethodGET
                   sourceObjectID:sourceObjectID
                        sessionID:captureId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              if ([parser parserError] != nil)
                                  self.numCaptureIdsAwaitingDownload--;
                          }
                          failure:NULL
     ];
}


- (void)downloadSuccessBlock:(NSString *)captureID sourceID:(NSURL *)sourceID maxSize:(float)maxSize
{
    float exponentialMultiplier = 0.5;
    if (!self.downloadSequenceResults) {
        self.downloadSequenceResults = [[NSMutableArray alloc] init];
    }
    
    if (self.currentWSBDResult.status == StatusSuccess) {
        //add the current download result to the list.
        [self.downloadSequenceResults addObject:self.currentWSBDResult];
        self.numCaptureIdsAwaitingDownload--;
        if (self.numCaptureIdsAwaitingDownload <= 0) {
            if(self.sequenceInProgress == kSensorSequenceCaptureDownload ||
               self.sequenceInProgress == kSensorSequenceConfigCaptureDownload)
            {
                if ([[self delegate] respondsToSelector:@selector(configCaptureDownloadSequenceCompletedFromLink:withResults:sourceObjectID:)]) {
                    [[self delegate] configCaptureDownloadSequenceCompletedFromLink:self withResults:self.downloadSequenceResults sourceObjectID:sourceID];
                }
            }
            else if (self.sequenceInProgress == kSensorSequenceFull)
            {
                if ([[self delegate] respondsToSelector:@selector(fullSequenceCompletedFromLink:withResults:sourceObjectID:)]) {
                    [[self delegate] fullSequenceCompletedFromLink:self withResults:self.downloadSequenceResults sourceObjectID:sourceID];
                }
            }
            _sequenceInProgress = kSensorSequenceNone;
            self.numCaptureIdsAwaitingDownload = 0;
        }
        //remove any retry counter attached to this request.
        if (captureID) {
            [self.downloadRetryCount removeObjectForKey:captureID];
        }
    }
    
    //Otherwise, if we're configured to retry automatically, do it.
    else if (self.currentWSBDResult.status == StatusPreparingDownload && kShouldRetryDownloadIfPending)
    {
        //do an exponential back-off
        int currentCaptureRetryCount = [[self.downloadRetryCount objectForKey:captureID] intValue];
        //figure out the current retry interval
        NSTimeInterval currentCaptureInterval = (2^currentCaptureRetryCount - 1) * exponentialMultiplier;
        
        while (currentCaptureInterval < self.exponentialIntervalMax) {
            
            [NSThread sleepForTimeInterval:currentCaptureInterval]; //NOTE: we may need to run these *Completed methods on their own threads to avoid blocking the queue...?
            //put a new attempt at this download in the queue.
            [self download:captureID withMaxSize:maxSize sourceObjectID:sourceID];
            
            //increase the retry count
            [self.downloadRetryCount setObject:[NSNumber numberWithInt:(currentCaptureRetryCount + 1)] forKey:captureID];
        }
        
    }
}

- (void)download:(NSString *)captureId sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeDownload
                       withMethod:kBCLMethodGET
                   sourceObjectID:sourceID
                        sessionID:captureId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              [self downloadSuccessBlock:captureId sourceID:sourceID maxSize:self.downloadMaxSize];
                          }
                          failure:NULL
     ];
}

- (void)download:(NSString *)captureId withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID
{
    [self enqueueNetworkOperation:kOpTypeThriftyDownload
                       withMethod:kBCLMethodGET
                   sourceObjectID:sourceID
                        sessionID:captureId
                       parameters:nil
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                              [self downloadSuccessBlock:captureId sourceID:sourceID maxSize:maxSize];
                          }
                          failure:NULL
     ];
}

#pragma mark - State Machine

- (BOOL)beginConnectSequenceWithSourceObjectID:(NSURL *)sourceObjectID
{
    // Don't start another sequence if one is in progress
    if (self.sequenceInProgress)
        return (NO);
    
    //kick off the connection sequence
    _sequenceInProgress = kSensorSequenceConnect;
    [self registerClient:sourceObjectID];
    return (YES);
}

- (BOOL)beginConnectConfigureSequenceWithConfigurationParams:(NSMutableDictionary *)params sourceObjectID:(NSURL *)sourceID
{
    // Don't start another sequence if one is in progress
    if (self.sequenceInProgress)
        return (NO);
    
    // Kick off the connection sequence
    _sequenceInProgress = kSensorSequenceConnectConfigure;
    self.pendingConfiguration = params;
    [self registerClient:sourceID];
    
    return (YES);
}

- (BOOL)beginConfigCaptureDownloadSequence:(NSString *)sessionId configurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID
{
    // Don't start another sequence if one is in progress
    if (self.sequenceInProgress)
        return (NO);
    
    // Configure the capture sequence
    _sequenceInProgress = kSensorSequenceConfigCaptureDownload;
    self.downloadMaxSize = maxSize;
    self.pendingConfiguration = params;
    
    // Start by grabbing the lock
    [self lock:sessionId sourceObjectID:sourceID];
    
    return (YES);
}

- (BOOL)beginFullSequenceWithConfigurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID
{
    // Don't start another sequence if one is in progress
    if (self.sequenceInProgress)
        return (NO);
    
    // Configure the capture sequence
    _sequenceInProgress = kSensorSequenceFull;
    self.downloadMaxSize = maxSize;
    self.pendingConfiguration = params;
    
    // Start by registering with the service
    [self registerClient:sourceID];
    
    return (YES);
}


- (void)attemptWSBDSequenceRecovery:(NSURL *)sourceObjectID
{
    NSLog(@"Attempting to recover from a WS-BD issue: %@",[WSBDResult stringForStatusValue:self.currentWSBDResult.status]);
    
    //If we got an unsuccessful result, and haven't already tried to recover, do so now.
    self.storedSequence = self.sequenceInProgress;
    _sequenceInProgress = kSensorSequenceRecovery;
    
    //Figure out where we need to go.
    //FIXME: We need to handle all potential status values here!
    switch (self.currentWSBDResult.status) {
        case StatusInvalidId:
            //need to re-register
            [self registerClient:sourceObjectID];
            break;
        case StatusLockHeldByAnother:
            //try once to steal the lock.
            [self lock:self.currentSessionId sourceObjectID:sourceObjectID];
            break;
        case StatusSensorNeedsInitialization:
            //We need to run initialization again.
            [self initialize:self.currentSessionId sourceObjectId:sourceObjectID];
            break;
        case StatusSensorNeedsConfiguration:
            //We need to run configuration again.
            [self setConfiguration:self.currentSessionId withParameters:self.pendingConfiguration sourceObjectID:sourceObjectID];
            break;
        case StatusNoSuchParameter:
            //We need to run configuration again.
            [self setConfiguration:self.currentSessionId withParameters:self.pendingConfiguration sourceObjectID:sourceObjectID];
            break;
        case StatusSensorFailure:
            //try to reinitialize.
            [self initialize:self.currentSessionId sourceObjectId:sourceObjectID];
            break;
        default:
            //don't recover
            _sequenceInProgress = kSensorSequenceNone;
            [[self delegate] sensorOperationDidFail:kSensorSequenceRecovery fromLink:self sourceObjectID:sourceObjectID withError:nil];
            break;
    }
    
}

@end
