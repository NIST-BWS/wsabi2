//
//  NBCLDeviceLinkManager.h
//  wsabi2
//
//  Created by Matt Aronoff on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBCLDeviceLink.h"
#import "NBCLInternalCameraSensorLink.h"
#import "NBCLDeviceLinkConstants.h"
#import "WSCDItem.h"
#import "constants.h"

@interface NBCLDeviceLinkManager : NSObject <NBCLDeviceLinkDelegate>
{
    NSMutableDictionary *devices;
}

+ (NBCLDeviceLinkManager *) defaultManager;

- (NBCLDeviceLink *) deviceForUri:(NSString*)uri;

//Returns YES if creation was successful.
//Otherwise, returns NO if that uri already contains a device link.
- (BOOL) createDeviceForUri:(NSString*)uri;

@end
