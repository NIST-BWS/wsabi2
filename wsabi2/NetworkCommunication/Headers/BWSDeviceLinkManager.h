//
//  NBCLDeviceLinkManager.h
//  wsabi2
//
//  Created by Matt Aronoff on 3/19/12.
 
//

#import <Foundation/Foundation.h>
#import "BWSDeviceLink.h"
#import "BWSDeviceLinkConstants.h"
#import "BWSCDItem.h"
#import "BWSConstants.h"

@interface BWSDeviceLinkManager : NSObject <BWSDeviceLinkDelegate>
{
    NSMutableDictionary *devices;
}

+ (BWSDeviceLinkManager *) defaultManager;

//This will create a new link if one doesn't exist at the specified uri.
- (BWSDeviceLink *) deviceForUri:(NSString*)uri;

@end
