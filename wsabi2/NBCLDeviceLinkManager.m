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
    if (!devices) {
        return nil;
    }
    
    return [devices objectForKey:uri];
}

//Returns YES if creation was successful.
//Otherwise, returns NO if that uri already contains a device link.
- (BOOL) createDeviceForUri:(NSString*)uri;
{
    if (!devices) {
        devices = [[NSMutableDictionary alloc] init];
    }
    
    if ([devices objectForKey:uri]) {
        //something's already here. Return NO.
        return NO;
    }
    else {
        //If this is one of our special local URIs, create a local sensor link.
        //If this is a sensor at a normal URI, create a normal sensor link.
        NBCLDeviceLink *newLink = nil;
        
        if ([uri hasPrefix:kLocalCameraURLPrefix]) {
            newLink = [[NBCLInternalCameraSensorLink alloc] init];
        }
        else {
            newLink = [[NBCLDeviceLink alloc] init];
        }
        
        newLink.uri = uri;
        
        //set the link delegate so we get messages when stuff happens.
        newLink.delegate = self;
        
        //add the link to the array.
        [devices setObject:newLink forKey:uri];
        
        //attempt to connect this sensor, stealing the lock if necessary.
        BOOL sequenceStarted = [newLink beginConnectSequence:YES withSenderTag:-1];
        if (!sequenceStarted) {
            NSLog(@"Couldn't start sensor connect sequence for sensor at %@",uri);
        }
        return YES;
    }
}

#pragma mark - Sensor Link Delegate methods
-(void) sensorOperationDidFail:(int)opType fromLink:(NBCLDeviceLink*)link withSenderTag:(int)senderTag withError:(NSError *)error
{

    //Post a notification about the failed operation, containing the error, so we can do something with it.
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     error, @"error",
                                     [NSNumber numberWithInt:senderTag], @"tag",
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationFailed
                                                        object:self
                                                      userInfo:userInfo];

    
    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ had %@ fail: %@", link.uri, [NBCLDeviceLink stringForOpType:opType], [error description]);
    
}

-(void) sensorOperationWasCancelledByService:(int)opType fromLink:(NBCLDeviceLink*)link withSenderTag:(int)senderTag withResult:(WSBDResult*)result
{
    
}

-(void) sensorOperationWasCancelledByClient:(int)opType fromLink:(NBCLDeviceLink*)link withSenderTag:(int)senderTag
{
    
}

-(void) sensorOperationCompleted:(int)opType fromLink:(NBCLDeviceLink*)link withSenderTag:(int)senderTag withResult:(WSBDResult*)result
{
    //Post a notification about the completed operation!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:senderTag], @"tag",
                                     result, @"result",
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkOperationCompleted
                                                        object:self
                                                      userInfo:userInfo];

    NSLog(@"Link at %@ completed %@ with status %@", link.uri, [NBCLDeviceLink stringForOpType:opType], [WSBDResult stringForStatusValue:result.status]);    
    
}

-(void) sensorConnectionStatusChanged:(BOOL)connectedAndReady fromLink:(NBCLDeviceLink*)link withSenderTag:(int)senderTag
{

    //Post a notification about the status change containing the new value
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:senderTag], @"tag",
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
-(void) sensorConnectSequenceCompletedFromLink:(NBCLDeviceLink*)link withResult:(WSBDResult*)result withSenderTag:(int)senderTag
{
    //Post a notification about the completed sequence!
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:senderTag], @"tag",
                                     nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSensorLinkConnectSequenceCompleted
                                                        object:self
                                                      userInfo:userInfo];

    //add this result to the WS-BD Result cache (at the top)
    NSLog(@"Link at %@ completed its connect sequence", link.uri);
}

-(void) sensorCaptureSequenceCompletedFromLink:(NBCLDeviceLink*)link withResults:(NSMutableArray*)results withSenderTag:(int)tag
{
//    //Get the data objects for the current collection so we can modify them as necessary.
//    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
//    NSArray *sortedDataObjects = [self.activeCollection.items sortedArrayUsingDescriptors:sortDescriptors];
    
//    BiometricData *theData = [sortedDataObjects objectAtIndex:(tag - CAPTURER_TAG_OFFSET)];
//    WsabiDeviceView_iPad *theCapturer = (WsabiDeviceView_iPad*)[self.capturerScroll viewWithTag:tag];
//    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];

    //Each of the results represents one downloaded object.
    for (int i = 0; i < [results count]; i++) {
        WSBDResult *currentResult = [results objectAtIndex:i];
        
        //FIXME: Post a notification containing this WSBDResult as attached data.
        
    }
}

-(void) sensorDisconnectSequenceCompletedFromLink:(NBCLDeviceLink*)link withResult:(WSBDResult*)result withSenderTag:(int)senderTag shouldReleaseIfSuccessful:(BOOL)shouldRelease;
{
//    NBCLSensorLink *sensorLink = link;
//    if (result.status == StatusSuccess) {
//        NSLog(@"Successfully disconnected from sensor at URI %@",sensorLink.uri);
//        
//        if (shouldRelease) {
//            [link release]; //release the link object
//        }
//    }
    
}

@end
