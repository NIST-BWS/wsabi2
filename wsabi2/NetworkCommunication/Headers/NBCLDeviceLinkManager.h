//
//  NBCLDeviceLinkManager.h
//  wsabi2
//
//  Created by Matt Aronoff on 3/19/12.
 
//

#import <Foundation/Foundation.h>
#import "WSDeviceLink.h"
#import "NBCLInternalCameraSensorLink.h"
#import "NBCLDeviceLinkConstants.h"
#import "WSCDItem.h"
#import "constants.h"

@interface NBCLDeviceLinkManager : NSObject <WSDeviceLinkDelegate>
{
    NSMutableDictionary *devices;
}

+ (NBCLDeviceLinkManager *) defaultManager;

//This will create a new link if one doesn't exist at the specified uri.
- (WSDeviceLink *) deviceForUri:(NSString*)uri;

@end
