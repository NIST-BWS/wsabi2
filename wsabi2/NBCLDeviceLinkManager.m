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

@end
