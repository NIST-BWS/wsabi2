//
//  NBCLDeviceLinkManager.m
//  wsabi2
//
//  Created by Matt Aronoff on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

- (NBCLDeviceLink *) deviceForUri:(NSString*)uri
{
    if (!uri) {
        NSLog(@"Tried to grab a device with no URI; ignoring request.");
        return nil;
    }
    
    if (!devices) {
        devices = [[NSMutableDictionary alloc] init];
    }
    
    NBCLDeviceLink *link = [devices objectForKey:uri];
    
    if (!link) {
        //If this is one of our special local URIs, create a local sensor link.
        //If this is a sensor at a normal URI, create a normal sensor link.
        
        if ([uri hasPrefix:kLocalCameraURLPrefix]) {
            link = [[NBCLInternalCameraSensorLink alloc] init];
        }
        else {
            link = [[NBCLDeviceLink alloc] init];
        }
        
        link.uri = uri;
        
        //set the link delegate so we get messages when stuff happens.
        link.delegate = self;
        
        //add the link to the array.
        [devices setObject:link forKey:uri];
        
        //attempt to connect this sensor, stealing the lock if necessary.
        BOOL sequenceStarted = [link beginConnectSequenceWithSourceObjectID:nil];
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
            BOOL sequenceStarted = [link beginConnectSequenceWithSourceObjectID:nil];
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
-(void) sensorOperationDidFail:(int)opType fromLink:(NBCLDeviceLink*)link sourceObjectID:(NSURL *)sourceID withError:(NSError *)error
{

    //Post a notification about the failed operation, containing the error, so we can do something with it.
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     error, @"error",
                                     sourceID, kDictKeySourceID,
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationFailed
                                                        object:self
                                                      userInfo:userInfo];

    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ had %@ fail: %@", link.uri, [NBCLDeviceLink stringForOpType:opType], [error description]);
    
}

-(void) sensorOperationWasCancelledByService:(int)opType fromLink:(NBCLDeviceLink*)link sourceObjectID:(NSURL *)sourceID withResult:(WSBDResult*)result
{
    
}

-(void) sensorOperationWasCancelledByClient:(int)opType fromLink:(NBCLDeviceLink*)link sourceObjectID:(NSURL *)sourceID
{
    //Post a notification about the failed operation, containing the error, so we can do something with it.
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationCancelledByClient
                                                        object:self
                                                      userInfo:userInfo];
    
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ cancelled operation: %@", link.uri, [NBCLDeviceLink stringForOpType:opType]);

}

-(void) sensorOperationCompleted:(int)opType fromLink:(NBCLDeviceLink*)link sourceObjectID:(NSURL *)sourceID withResult:(WSBDResult*)result
{
    //Post a notification about the completed operation!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
                                     result, kDictKeyCurrentResult,
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationCompleted
                                                        object:self
                                                      userInfo:userInfo];

    NSLog(@"Link at %@ completed %@ with status %@", link.uri, [NBCLDeviceLink stringForOpType:opType], [WSBDResult stringForStatusValue:result.status]);    
    
}

-(void) sensorConnectionStatusChanged:(BOOL)connectedAndReady fromLink:(NBCLDeviceLink*)link sourceObjectID:(NSURL *)sourceID
{

    //Post a notification about the status change containing the new value
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
                                     [NSNumber numberWithBool:connectedAndReady], @"connectedAndReadyStatus",
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectedStatusChanged
                                                        object:self
                                                      userInfo:userInfo];

    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ changed status to %@", link.uri, connectedAndReady ? @"ready" : @"not ready");

}


//NOTE: The result object will be the result from the last performed step;
//so if the sequence succeeds, it'll be the last step in the sequence; otherwise
//it'll be the step that failed, so that the status will indicate what the problem was.
-(void) connectSequenceCompletedFromLink:(NBCLDeviceLink*)link withResult:(WSBDResult*)result sourceObjectID:(NSURL *)sourceID
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];

    if (sourceID)
        [userInfo setObject:sourceID forKey:kDictKeySourceID];
    if (link)
        [userInfo setObject:link forKey:kDictKeySourceLink];
    if (result) 
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];

    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its connect sequence", link.uri);
}

-(void) configureSequenceCompletedFromLink:(NBCLDeviceLink*)link 
                                withResult:(WSBDResult*)result 
                             sourceObjectID:(NSURL *)sourceID;
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConfigureSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its configure sequence", link.uri);

}

-(void) connectConfigureSequenceCompletedFromLink:(NBCLDeviceLink *)link 
                                       withResult:(WSBDResult *)result 
                                    sourceObjectID:(NSURL *)sourceID
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectConfigureSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its connect & configure sequence", link.uri);

}

- (void) processDownloadResultsFromLink:(NBCLDeviceLink*)link withResults:(NSMutableArray*)results sourceObjectID:(NSURL *)sourceID
{
    if (!results) {
        NSLog(@"Link at %@ reached the end of a capture sequence, but had no results.",link.uri);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
    
    //Each of the results represents one downloaded object.
    for (int i = 0; i < [results count]; i++) {
        WSBDResult *currentResult = [results objectAtIndex:i];
        
        if (currentResult.status != StatusSuccess) {
            NSLog(@"Link at %@ had a failure: %@ %@",link.uri, [WSBDResult stringForStatusValue:currentResult.status], currentResult.message);
        }
        //FIXME: Post a notification containing this WSBDResult as attached data.
        //Post a notification about the status change containing the new value
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         sourceID, kDictKeySourceID,
                                         currentResult.metadata, @"metadata",
                                         currentResult.downloadData, @"data",
                                         nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkDownloadPosted
                                                            object:self
                                                          userInfo:userInfo];
        
        //add this result to the WS-BD Result cache (at the top)
        NSLog(@"Link at %@ completed downloading one capture result", link.uri);
    }

}

-(void) configCaptureDownloadSequenceCompletedFromLink:(NBCLDeviceLink*)link withResults:(NSMutableArray*)results sourceObjectID:(NSURL *)sourceID
{
    [self processDownloadResultsFromLink:link withResults:results sourceObjectID:sourceID];
}

-(void) fullSequenceCompletedFromLink:(NBCLDeviceLink *)link withResults:(NSMutableArray *)results sourceObjectID:(NSURL *)sourceID
{
    [self processDownloadResultsFromLink:link withResults:results sourceObjectID:sourceID];
}

-(void) disconnectSequenceCompletedFromLink:(NBCLDeviceLink*)link 
                                 withResult:(WSBDResult*)result 
                             sourceObjectID:(NSURL*)sourceID
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
                                     nil];
    if (result) {
        [userInfo setObject:result forKey:kDictKeyCurrentResult];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkDisconnectSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];
    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its disconnect sequence", link.uri);
    
}

//Called whenever a sequence doesn't complete 
//(because, for example, one included step returned a non-success result.
-(void) sequenceDidFail:(SensorSequenceType)sequenceType
                     fromLink:(NBCLDeviceLink*)link 
                   withResult:(WSBDResult*)result 
                sourceObjectID:(NSURL *)sourceID
{
    
    //first, try to unlock.
    [link beginUnlock:link.currentSessionId sourceObjectID:sourceID];
    
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     sourceID, kDictKeySourceID,
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
    NSLog(@"Link at %@ failed to complete a series of operations", link.uri);

    //If this sequence fails, for now, go all the way back and start over.
    link.registered = NO;
    link.initialized = NO;
    
}

@end
