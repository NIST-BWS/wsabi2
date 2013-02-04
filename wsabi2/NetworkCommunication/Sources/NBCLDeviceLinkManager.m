//
//  NBCLDeviceLinkManager.m
//  wsabi2
//
//  Created by Matt Aronoff on 3/19/12.
 
//

#import "NBCLDeviceLinkManager.h"

@implementation NBCLDeviceLinkManager

+ (NBCLDeviceLinkManager *) defaultManager
{
    static NBCLDeviceLinkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NBCLDeviceLinkManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (BWSDeviceLink *) deviceForUri:(NSString*)uri
{
    if (!uri) {
        NSLog(@"Tried to grab a device with no URI; ignoring request.");
        return nil;
    }
    
    if (!devices) {
        devices = [[NSMutableDictionary alloc] init];
    }
    
    BWSDeviceLink *link = [devices objectForKey:uri];
    
    if (!link) {
//        //If this is one of our special local URIs, create a local sensor link.
//        //If this is a sensor at a normal URI, create a normal sensor link.
//        
//        if ([uri hasPrefix:kLocalCameraURLPrefix]) {
//            link = [[NBCLInternalCameraSensorLink alloc] init];
//        }
//        else {
        link = [[BWSDeviceLink alloc] initWithBaseURI:uri];
//        }
        
        //set the link delegate so we get messages when stuff happens.
        link.delegate = self;
        
        //add the link to the array.
        [devices setObject:link forKey:uri];
        
        //attempt to connect this sensor, stealing the lock if necessary.
        BOOL sequenceStarted = [link beginConnectSequenceWithDeviceID:nil];
        if (!sequenceStarted) {
            NSLog(@"NBCLDeviceLinkManager: Couldn't start sensor connect sequence for %@",uri);
            //this failed.
            //[self sequenceDidFail:kSensorSequenceConnect fromLink:link withResult:nil sourceObjectID:nil];
        }
        else {
            NSLog(@"NBCLDeviceLinkManager: Started sensor connect sequence for %@",uri);
        }
        
    }
    else {
        //if the sensor isn't initialized (well, if we don't think it is), re-initialize it.
        if (!link.initialized) {
            //if we're supposed to reinitialize any links we find, do so
            //attempt to connect this sensor, stealing the lock if necessary.
            BOOL sequenceStarted = [link beginConnectSequenceWithDeviceID:nil];
            if (!sequenceStarted) {
                NSLog(@"NBCLDeviceLinkManager: Couldn't start sensor connect sequence for %@",uri);
                //this failed.
                //[self sequenceDidFail:kSensorSequenceConnect fromLink:link withResult:nil sourceObjectID:nil];
            }
            else {
                NSLog(@"NBCLDeviceLinkManager: Started sensor connect sequence for %@",uri);
            }

        }
    }

    return link;
}

#pragma mark - Sensor Link Delegate methods
-(void) sensorOperationDidFail:(SensorOperationType)opType fromLink:(BWSDeviceLink*)link deviceID:(NSURL *)deviceID withError:(NSError *)error
{

    //Post a notification about the failed operation, containing the error, so we can do something with it.
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     error, @"error",
                                     deviceID, kDictKeyDeviceID,
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationFailed
                                                        object:self
                                                      userInfo:userInfo];

    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ had %@ fail: %@", link.baseURI, [BWSDeviceLink stringForSensorOperationType:opType], [error description]);
    
}

-(void) sensorOperationWasCancelledByClient:(SensorOperationType)opType fromLink:(BWSDeviceLink*)link deviceID:(NSURL *)deviceID
{
    //Post a notification about the failed operation, containing the error, so we can do something with it.
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationCancelledByClient
                                                        object:self
                                                      userInfo:userInfo];
    
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ cancelled operation: %@", link.baseURI, [BWSDeviceLink stringForSensorOperationType:opType]);

}

-(void) sensorOperationCompleted:(SensorOperationType)opType fromLink:(BWSDeviceLink*)link deviceID:(NSURL *)deviceID withResult:(WSBDResult*)result
{
    //Post a notification about the completed operation!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     result, kDictKeyCurrentResult,
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationCompleted
                                                        object:self
                                                      userInfo:userInfo];

    NSLog(@"Link at %@ completed %@ with status %@", link.baseURI, [BWSDeviceLink stringForSensorOperationType:opType], [WSBDResult stringForStatusValue:result.status]);
    
}

-(void) sensorConnectionStatusChanged:(BOOL)connectedAndReady fromLink:(BWSDeviceLink*)link deviceID:(NSURL *)deviceID
{

    //Post a notification about the status change containing the new value
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     [NSNumber numberWithBool:connectedAndReady], @"connectedAndReadyStatus",
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectedStatusChanged
                                                        object:self
                                                      userInfo:userInfo];

    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ changed status to %@", link.baseURI, connectedAndReady ? @"ready" : @"not ready");

}


//NOTE: The result object will be the result from the last performed step;
//so if the sequence succeeds, it'll be the last step in the sequence; otherwise
//it'll be the step that failed, so that the status will indicate what the problem was.
-(void) connectSequenceCompletedFromLink:(BWSDeviceLink*)link withResult:(WSBDResult*)result deviceID:(NSURL *)deviceID
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];

    if (deviceID)
        [userInfo setObject:deviceID forKey:kDictKeyDeviceID];
    if (link)
        [userInfo setObject:link forKey:kDictKeySourceLink];
    if (result) 
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];

    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its connect sequence", link.baseURI);
}

-(void) configureSequenceCompletedFromLink:(BWSDeviceLink*)link
                                withResult:(WSBDResult*)result 
                                  deviceID:(NSURL *)deviceID;
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConfigureSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its configure sequence", link.baseURI);

}

-(void) connectConfigureSequenceCompletedFromLink:(BWSDeviceLink *)link
                                       withResult:(WSBDResult *)result 
                                         deviceID:(NSURL *)deviceID
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectConfigureSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its connect & configure sequence", link.baseURI);

}

- (void) processDownloadResultsFromLink:(BWSDeviceLink*)link withResults:(NSMutableArray*)results deviceID:(NSURL *)deviceID
{
    if (!results) {
        NSLog(@"Link at %@ reached the end of a capture sequence, but had no results.",link.baseURI);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
    
    //Each of the results represents one downloaded object.
    for (int i = 0; i < [results count]; i++) {
        WSBDResult *currentResult = [results objectAtIndex:i];
        
        if (currentResult.status != StatusSuccess) {
            NSLog(@"Link at %@ had a failure: %@ %@",link.baseURI, [WSBDResult stringForStatusValue:currentResult.status], currentResult.message);
        }
        //FIXME: Post a notification containing this WSBDResult as attached data.
        //Post a notification about the status change containing the new value
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         deviceID, kDictKeyDeviceID,
                                         currentResult.metadata, @"metadata",
                                         currentResult.downloadData, @"data",
                                         nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkDownloadPosted
                                                            object:self
                                                          userInfo:userInfo];
        
        //add this result to the WS-BD Result cache (at the top)
        NSLog(@"Link at %@ completed downloading one capture result", link.baseURI);
    }

}

-(void) configCaptureDownloadSequenceCompletedFromLink:(BWSDeviceLink*)link withResults:(NSMutableArray*)results deviceID:(NSURL *)deviceID
{
    [self processDownloadResultsFromLink:link withResults:results deviceID:deviceID];
}

-(void) fullSequenceCompletedFromLink:(BWSDeviceLink *)link withResults:(NSMutableArray *)results deviceID:(NSURL *)deviceID
{
    [self processDownloadResultsFromLink:link withResults:results deviceID:deviceID];
}

-(void) disconnectSequenceCompletedFromLink:(BWSDeviceLink*)link
                                 withResult:(WSBDResult*)result 
                                   deviceID:(NSURL*)deviceID
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkDisconnectSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its disconnect sequence", link.baseURI);
    
}

//Called whenever a sequence doesn't complete 
//(because, for example, one included step returned a non-success result.
-(void) sequenceDidFail:(SensorSequenceType)sequenceType
               fromLink:(BWSDeviceLink*)link
             withResult:(WSBDResult*)result 
               deviceID:(NSURL *)deviceID
{
    
    //first, try to unlock.
    [link unlock:link.currentSessionId deviceID:deviceID];
    
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     deviceID, kDictKeyDeviceID,
                                     [NSNumber numberWithInt:sequenceType], kDictKeySequenceType,
                                     [WSBDResult stringForStatusValue:result.status], kDictKeyMessage,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkSequenceFailed
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ failed to complete a series of operations", link.baseURI);    
}

@end
