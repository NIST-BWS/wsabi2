//
//  WSDeviceChooserController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import "WSModalityMap.h"
#import "WSCDItem.h"
#import "WSDeviceSetupController.h"

@interface WSDeviceChooserController : UITableViewController
{
    NSArray *recentSensors;
}

@property (nonatomic) BOOL autodiscoveryEnabled;
@property (nonatomic) WSSensorCaptureType submodality;
@property (nonatomic) WSSensorModalityType modality;

@property (nonatomic, strong) WSCDItem *item;

@end
