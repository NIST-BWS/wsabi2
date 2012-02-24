//
//  WSModalityChooserController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSModalityMap.h"
#import "WSSubmodalityChooserController.h"
#import "WSDeviceConfigDelegate.h"

@interface WSModalityChooserController : UITableViewController

-(IBAction) cancelButtonPressed:(id)sender;

@property (nonatomic, strong) WSCDItem *item;
@property (nonatomic, unsafe_unretained) id<WSDeviceConfigDelegate> walkthroughDelegate;

@end
