//
//  WSDeviceChooserController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import "NSManagedObject+DeepCopy.h"
#import "WSModalityMap.h"
#import "WSCDItem.h"
#import "WSDeviceSetupController.h"
#import "WSDeviceConfigDelegate.h"

#define NUM_RECENT_SENSORS 5

@interface WSDeviceChooserController : UITableViewController
{
    NSArray *recentSensors;
}

-(IBAction) cancelButtonPressed:(id)sender;

@property (nonatomic) BOOL autodiscoveryEnabled;
@property (nonatomic) WSSensorCaptureType submodality;
@property (nonatomic) WSSensorModalityType modality;

@property (nonatomic, strong) WSCDItem *item;

@property (nonatomic, unsafe_unretained) id<WSDeviceConfigDelegate> walkthroughDelegate;
@end
