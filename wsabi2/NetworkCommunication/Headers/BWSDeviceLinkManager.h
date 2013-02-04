// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

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
