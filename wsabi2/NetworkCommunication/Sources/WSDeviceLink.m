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

#import "WSDeviceLink.h"

#import "AFXMLRequestOperation.h"

@interface WSDeviceLink ()

@property (nonatomic, assign) NSInteger operationInProgress;
@property (nonatomic, assign) NSInteger operationPendingCancellation;

@property (nonatomic, assign) SensorSequenceType storedSequence;

- (void)setSensorOperationFailedForOperation:(AFHTTPRequestOperation *)operation;

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

//The configuration to be used in case we're running a capture sequence rather than
//individual operations (in which case we need a place to put the config while we're progressing).
@property (nonatomic, strong) NSMutableDictionary *pendingConfiguration;

@end

@implementation WSDeviceLink

- (id)initWithBaseURI:(NSURL *)uri
{
    self = [super init];
    if (self == nil)
        return (nil);

    _baseURI = uri;
    _XMLParser = [[NSXMLParser alloc] init];
    [_XMLParser setDelegate:self];
    
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

#pragma mark - Common Handling

- (void)notifyCompletedOperation:(NSInteger)operation withSourceObjectID:sourceObjectID
{
    if ([[self delegate] respondsToSelector:@selector(sensorOperationCompleted:fromLink:sourceObjectID:withResult:)]) {
        [[self delegate] sensorOperationCompleted:operation
                                         fromLink:self
                                   sourceObjectID:sourceObjectID
                                       withResult:self.currentWSBDResult];
    }
}

- (BOOL)isSuccessValidWithOperation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject
{
    // Check HTTP return status
    if ([operation hasAcceptableStatusCode] == NO)
        return (NO);
    
    return (YES);
}

- (BOOL)isSuccessValidWithResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject
{
    // Check HTTP return status
    if (([response statusCode] / 100) >= 3)
        return (NO);

    return (YES);
}

- (void)setSensorOperationFailedForOperation:(AFHTTPRequestOperation *)operation withUserInfo:(NSDictionary *)userInfo
{
    [self setSensorOperationFailedWithResponse:operation.response userInfo:userInfo];
}

- (void)setSensorOperationFailedWithResponse:(NSHTTPURLResponse *)response userInfo:(NSDictionary *)userInfo
{
    NSLog(@"Sensor operation failed with message %@ (%@)",
          [[response allHeaderFields] objectForKey:@"status"],
          [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]);
    
    if ([[self delegate] respondsToSelector:@selector(sensorOperationDidFail:fromLink:sourceObjectID:withError:)]) {
        [[self delegate] sensorOperationDidFail:[userInfo[@"opType"] intValue]
                                       fromLink:self
                                 sourceObjectID:userInfo[@"sourceID"]
                                      withError:nil];
    }
    
    [self setOperationInProgress:-1];
}

- (BOOL)parseSuccessfulOperation:(AFHTTPRequestOperation *)operation withUserInfo:(NSDictionary *)userInfo responseObject:(id)responseObject
{
    // Check for error messages
    if ([self isSuccessValidWithOperation:operation responseObject:responseObject] == NO) {
        [self setSensorOperationFailedForOperation:operation];
        return (NO);
    }
    
    // Parse the XML response from the service
    NSXMLParser *parser  = [[NSXMLParser alloc] initWithData:responseObject];
    [parser setDelegate:self];
    if ([parser parse] == NO) {
        [self setSensorOperationFailedForOperation:operation withUserInfo:userInfo];
        return (NO);
    }
    
    return (YES);
}

- (BOOL)parseSuccessfulResponse:(NSHTTPURLResponse *)response withUserInfo:(NSDictionary *)userInfo responseObject:(id)responseObject
{
    // Check for error messages
    if ([self isSuccessValidWithResponse:response responseObject:responseObject] == NO) {
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
#pragma mark Setup and Cleanup

- (void)registerClient:(NSURL *)sourceObjectID
{
    [self setOperationInProgress:kOpTypeRegister];
    WSBDAFHTTPClient *service = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    NSDictionary *userInfo = @{@"opType": [NSNumber numberWithInt:kOpTypeRegister], kDictKeySourceID : sourceObjectID};
    [service postPath:@"register"
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                              return;
                          
                          [self notifyCompletedOperation:kOpTypeRegister withSourceObjectID:sourceObjectID];
                          
                          if (self.currentWSBDResult.status == StatusSuccess) {
                              //set the registered convenience variable.
                              self.registered = YES;
                              //store the current session id.
                              self.currentSessionId = self.currentWSBDResult.sessionId;
                              //if this call is part of a sequence, call the next step.
                              if (self.sequenceInProgress)
                                  [self lock:self.currentSessionId sourceObjectID:sourceObjectID];
                          } else if (self.sequenceInProgress) {
                              self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                              if ([[self delegate] respondsToSelector:@selector(connectSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                  [[self delegate] connectSequenceCompletedFromLink:self
                                                                  withResult:self.currentWSBDResult
                                                              sourceObjectID:sourceObjectID];
                              }
                          }
                          self.operationInProgress = -1;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                          [self setSensorOperationFailedForOperation:operation];
                      }
     ];
}

- (void)unregisterClient:(NSString *)sessionId sourceObjectId:(NSURL *)sourceObjectID
{
    WSBDAFHTTPClient *unregisterRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeUnregister];
    NSDictionary *userInfo = @{@"opType": [NSNumber numberWithInt:kOpTypeUnregister], kDictKeySourceID : sourceObjectID};
    [unregisterRequest deletePath:[NSString stringWithFormat:@"register/%@", sessionId]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                              return;
                          
                          [self notifyCompletedOperation:kOpTypeUnregister withSourceObjectID:sourceObjectID];
                          
                          if (self.currentWSBDResult.status == StatusSuccess) {
                              //set the registered convenience variable.
                              self.registered = YES;
                              //store the current session id.
                              self.currentSessionId = self.currentWSBDResult.sessionId;
                              //if this call is part of a sequence, call the next step.
                              if (self.sequenceInProgress)
                                  [self lock:self.currentSessionId sourceObjectID:sourceObjectID];
                          } else if (self.sequenceInProgress) {
                              self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                              if ([[self delegate] respondsToSelector:@selector(connectSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                  [[self delegate] connectSequenceCompletedFromLink:self
                                                                         withResult:self.currentWSBDResult
                                                                     sourceObjectID:sourceObjectID];
                              }
                          }
                          self.operationInProgress = -1;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                          [self setSensorOperationFailedForOperation:operation];
                      }
     ];

}

- (void)initialize:(NSString *)sessionId sourceObjectId:(NSURL *)sourceID
{
    WSBDAFHTTPClient *initializeRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeRegister];
    NSDictionary *userInfo = @{@"opType": [NSNumber numberWithInt:kOpTypeInitialize], kDictKeySourceID : sourceID};
    [initializeRequest postPath:[NSString stringWithFormat:@"initialize/%@", sessionId]
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                              return;
                          
                        [self notifyCompletedOperation:kOpTypeInitialize withSourceObjectID:sourceID];
                            
                          if (self.currentWSBDResult.status == StatusSuccess) {
                              //set the initialization convenience variable.
                              self.initialized = YES;
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
                                  self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                  
                              }
                          }
                          
                          self.operationInProgress = -1;

                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                          [self setSensorOperationFailedForOperation:operation];
                          [self unlock:sessionId sourceObjectID:sourceID];
                      }
     ];
}

- (void)cancel:(NSString *)sessionId sourceObjectID:(NSURL *)sourceObjectID
{
    WSBDAFHTTPClient *service = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeCancel];
    NSDictionary *userInfo = @{@"opType": [NSNumber numberWithInt:kOpTypeCancel], kDictKeySourceID : sourceObjectID};
    [service postPath:[NSString stringWithFormat:@"cancel/%@", sessionId]
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                      return;
                  
                  [self notifyCompletedOperation:kOpTypeCancel withSourceObjectID:sourceObjectID];
                  
                  //cancel any sequence that was in progress.
                  if (self.sequenceInProgress) {
                      if ([[self delegate] respondsToSelector:@selector(sequenceDidFail:fromLink:withResult:sourceObjectID:)]) {
                          [[self delegate] sequenceDidFail:self.sequenceInProgress
                                                  fromLink:self
                                                withResult:self.currentWSBDResult
                                            sourceObjectID:sourceObjectID
                           ];
                      }
                      self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                      
                  }
                  
                  
                  //Fire sensorOperationWasCancelled* in the delegate, and pass the opType
                  //of the *cancelled* operation.
                  if (self.operationPendingCancellation >= 0) {
                      if ([[self delegate] respondsToSelector:@selector(sensorOperationWasCancelledByClient:fromLink:sourceObjectID:)]) {
                          [[self delegate] sensorOperationWasCancelledByClient:self.operationPendingCancellation fromLink:self sourceObjectID:sourceObjectID];
                      }
                  }
                  
                  self.operationInProgress = -1;
                  self.operationPendingCancellation = -1;
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                  [self setSensorOperationFailedForOperation:operation];
              }
     ];
}

#pragma mark Configuration

- (void)setConfiguration:(NSString *)sessionId withParameters:(NSDictionary *)params sourceObjectID:(NSURL *)sourceID
{
    [self setOperationInProgress:kOpTypeConfigure];
    WSBDAFHTTPClient *client = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    NSMutableURLRequest *configureRequest = [client requestWithMethod:@"POST" path:[NSString stringWithFormat:@"configure/%@", sessionId] parameters:nil];
    NSDictionary *userInfo = @{@"opType": [NSNumber numberWithInt:kOpTypeInitialize], kDictKeySourceID : sourceID};
    
    // Assemble XML configuration message
    NSMutableString *messageBody = [NSMutableString stringWithFormat:@"<configuration %@ %@ %@>", kBCLSchemaInstanceNamespace, kBCLSchemaNamespace, kBCLWSBDNamespace];
	if (params)
        for(NSString* key in params)
            [messageBody appendFormat:@"<item><key>%@</key>%@</item>", key, [NBCLXMLMap xmlElementForObject:[params objectForKey:key] withElementName:@"value"]];
    [messageBody appendString:@"</configuration>"];
    [configureRequest setHTTPBody:[messageBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFXMLRequestOperation *operation;
    operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:configureRequest
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *parser) {
                                                            if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:nil] == NO)
                                                                return;
                                                            
                                                            [self notifyCompletedOperation:kOpTypeConfigure withSourceObjectID:sourceID];
                                                            
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
                                                                    self.sequenceInProgress = kSensorSequenceNone;
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
                                                                    self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                                                    
                                                                    //Try to force an unlock
                                                                    [self unlock:self.currentSessionId sourceObjectID:sourceID];
                                                                    
                                                                }
                                                            }
                                                            self.operationInProgress = -1;

                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *parser) {
                                                            [self setSensorOperationFailedForOperation:operation];
                                                            [self unlock:sessionId sourceObjectID:sourceID];
                                                        }
                 ];
    [client enqueueHTTPRequestOperation:operation];    
}

- (void)getConfiguration:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    WSBDAFHTTPClient *configureRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeConfigure];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeConfigure], kDictKeySourceID : sourceID};
    [configureRequest getPath:[NSString stringWithFormat:@"configure/%@", sessionId]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                              return;
                          
                          [self notifyCompletedOperation:kOpTypeGetConfiguration withSourceObjectID:sourceID];
                          
                          self.operationInProgress = -1;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                          [self setSensorOperationFailedForOperation:operation];
                      }
     ];
}

- (void)getServiceInfo:(NSURL *)sourceID
{
    WSBDAFHTTPClient *configureRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeGetCommonInfo];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeGetCommonInfo], kDictKeySourceID : sourceID};
    [configureRequest getPath:@"info"
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                              return;
                          
                          [self notifyCompletedOperation:kOpTypeGetCommonInfo withSourceObjectID:sourceID];
                          
                          self.operationInProgress = -1;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                          [self setSensorOperationFailedForOperation:operation];
                      }
     ];
}

#pragma mark Locking and Unlocking

- (void)lock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    WSBDAFHTTPClient *lockRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeLock];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeLock], kDictKeySourceID : sourceID};
    [lockRequest postPath:[NSString stringWithFormat:@"lock/%@", sessionId]
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                          return;
                      
                      [self notifyCompletedOperation:kOpTypeLock withSourceObjectID:sourceID];

                      if (self.currentWSBDResult.status == StatusSuccess) {
                          //set the lock convenience variable.
                          self.hasLock = YES;
                          
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
                              self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                              
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
                      
                      self.operationInProgress = -1;
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                      [self setSensorOperationFailedForOperation:operation];
                      [self unlock:sessionId sourceObjectID:sourceID];
                  }
     ];
}

- (void)stealLock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    WSBDAFHTTPClient *stealLockRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeStealLock];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeStealLock], kDictKeySourceID : sourceID};
    [stealLockRequest postPath:[NSString stringWithFormat:@"lock/%@", sessionId]
                    parameters:nil
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                               return;
                           
                           [self notifyCompletedOperation:kOpTypeStealLock withSourceObjectID:sourceID];
                           
                           if (self.currentWSBDResult.status == StatusSuccess) {
                               //set the lock convenience variable.
                               self.hasLock = YES;
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
                               self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                           }
                           
                           self.operationInProgress = -1;

                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                           [self setSensorOperationFailedForOperation:operation];
                       }
     ];
}

- (void)unlock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    WSBDAFHTTPClient *unlockRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeUnlock];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeUnlock], kDictKeySourceID : sourceID};
    [unlockRequest deletePath:[NSString stringWithFormat:@"lock/%@", sessionId]
                   parameters:nil
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                              return;
                          
                          [self notifyCompletedOperation:kOpTypeUnlock withSourceObjectID:sourceID];
                          
                          if (self.currentWSBDResult.status == StatusSuccess) {
                              //set the lock convenience variable.
                              self.hasLock = NO;
                              
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
                                  self.sequenceInProgress = self.storedSequence;
                                  
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
                                  self.sequenceInProgress = kSensorSequenceNone;
                                  if ([[self delegate] respondsToSelector:@selector(connectSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                      [[self delegate] connectSequenceCompletedFromLink:self
                                                                      withResult:self.currentWSBDResult
                                                                  sourceObjectID:sourceID];
                                  }
                              }
                              else if(self.sequenceInProgress == kSensorSequenceConfigure)
                              {
                                  //this is the end of the sequence.
                                  self.sequenceInProgress = kSensorSequenceNone;
                                  if ([[self delegate] respondsToSelector:@selector(configureSequenceCompletedFromLink:withResult:sourceObjectID:)]) {
                                      [[self delegate] configureSequenceCompletedFromLink:self
                                                                        withResult:self.currentWSBDResult
                                                                    sourceObjectID:sourceID];
                                  }
                              }
                              else if(self.sequenceInProgress == kSensorSequenceConnectConfigure)
                              {
                                  //this is the end of the sequence.
                                  self.sequenceInProgress = kSensorSequenceNone;
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
                              self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                          }
                          
                          self.operationInProgress = -1;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                          [self setSensorOperationFailedForOperation:operation];
                      }
     ];
}

#pragma mark Capture and Download

- (void)capture:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID
{
    WSBDAFHTTPClient *captureRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeCapture];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeCapture], kDictKeySourceID : sourceID};
    [captureRequest postPath:[NSString stringWithFormat:@"capture/%@", sessionId]
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO)
                             return;
                         
                         [self notifyCompletedOperation:kOpTypeCapture withSourceObjectID:sourceID];
                         
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
                                 self.sequenceInProgress = kSensorSequenceNone; //stop the sequence, as we've got a failure.
                                 //Try to force an unlock
                                 [self unlock:self.currentSessionId sourceObjectID:sourceID];
                             }
                         }
                         
                         self.operationInProgress = -1;
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                         [self setSensorOperationFailedForOperation:operation];
                     }
     ];

}

- (void)getDownloadInfo:(NSString *)captureId sourceObjectID:(NSURL *)sourceObjectID
{
    WSBDAFHTTPClient *service = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeGetContentType];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeGetContentType], kDictKeySourceID : sourceObjectID};
    [service getPath:[NSString stringWithFormat:@"download/%@", captureId]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO) {
                     self.numCaptureIdsAwaitingDownload--;
                     return;
                 }
                 
                 [self notifyCompletedOperation:kOpTypeGetContentType withSourceObjectID:sourceObjectID];
                 
                 self.operationInProgress = -1;
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                 [self setSensorOperationFailedForOperation:operation];
             }
     
     ];
}

- (void)download:(NSString *)captureId sourceObjectID:(NSURL *)sourceID
{
    [self download:captureId withMaxSize:self.downloadMaxSize sourceObjectID:sourceID];
}

- (void)download:(NSString *)captureId withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID
{
    WSBDAFHTTPClient *downloadRequest = [[WSBDAFHTTPClient alloc] initWithBaseURL:self.baseURI];
    [self setOperationInProgress:kOpTypeDownload];
    NSDictionary *userInfo = @{@"opType" : [NSNumber numberWithInt:kOpTypeDownload], kDictKeySourceID : sourceID};
    [downloadRequest getPath:[NSString stringWithFormat:@"download/%@/%1.0f", captureId, maxSize]
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         if ([self parseSuccessfulOperation:operation withUserInfo:userInfo responseObject:responseObject] == NO) {
                             self.numCaptureIdsAwaitingDownload--;
                             return;
                         }
                         
                         [self notifyCompletedOperation:kOpTypeDownload withSourceObjectID:sourceID];
                         
                         float exponentialMultiplier = 0.5;
                         NSString *currentId = [userInfo objectForKey:@"captureId"];
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
                                 self.sequenceInProgress = kSensorSequenceNone;
                                 self.numCaptureIdsAwaitingDownload = 0;
                             }
                             //remove any retry counter attached to this request.
                             if (currentId) {
                                 [self.downloadRetryCount removeObjectForKey:currentId];
                             }
                         }
                         
                         //Otherwise, if we're configured to retry automatically, do it.
                         else if (self.currentWSBDResult.status == StatusPreparingDownload && self.shouldRetryDownloadIfPending)
                         {
                             //do an exponential back-off
                             int currentCaptureRetryCount = [[self.downloadRetryCount objectForKey:currentId] intValue];
                             //figure out the current retry interval
                             NSTimeInterval currentCaptureInterval = (2^currentCaptureRetryCount - 1) * exponentialMultiplier;
                             
                             while (currentCaptureInterval < self.exponentialIntervalMax) {
                                 
                                 [NSThread sleepForTimeInterval:currentCaptureInterval]; //NOTE: we may need to run these *Completed methods on their own threads to avoid blocking the queue...?
                                 //put a new attempt at this download in the queue.
                                 [self download:currentId withMaxSize:maxSize sourceObjectID:sourceID];
                                 
                                 //increase the retry count
                                 [self.downloadRetryCount setObject:[NSNumber numberWithInt:(currentCaptureRetryCount + 1)] forKey:currentId];
                             }
                             
                         }
                         
                         self.operationInProgress = -1;

                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *failure) {
                         [self setSensorOperationFailedForOperation:operation];
                     }
     ];
     
}

#pragma mark - State Machine

- (BOOL)beginConnectSequenceWithSourceObjectID:(NSURL *)sourceObjectID
{
    // Don't start another sequence if one is in progress
    if (self.sequenceInProgress)
        return (NO);
    
    //kick off the connection sequence
    self.sequenceInProgress = kSensorSequenceConnect;
    [self registerClient:sourceObjectID];
    return (YES);
}

- (void)attemptWSBDSequenceRecovery:(NSURL *)sourceObjectID
{
    NSLog(@"Attempting to recover from a WS-BD issue: %@",[WSBDResult stringForStatusValue:self.currentWSBDResult.status]);
    
    //If we got an unsuccessful result, and haven't already tried to recover, do so now.
    self.storedSequence = self.sequenceInProgress;
    self.sequenceInProgress = kSensorSequenceRecovery;
    
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
            self.sequenceInProgress = kSensorSequenceNone;
            [[self delegate] sensorOperationDidFail:kSensorSequenceRecovery fromLink:self sourceObjectID:sourceObjectID withError:nil];
            break;
    }
    
}

@end
