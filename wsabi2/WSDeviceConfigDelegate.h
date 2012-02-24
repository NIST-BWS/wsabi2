//
//  WSDeviceConfigDelegate.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This is a common delegate available to each
// step of the sensor setup process.

#import <UIKit/UIKit.h>
#import "WSCDItem.h"

@protocol WSDeviceConfigDelegate <NSObject>

-(void) didCancelDeviceConfigWalkthrough:(WSCDItem*)sourceItem;
-(void) didCompleteDeviceConfigWalkthrough:(WSCDItem*)sourceItem;

@end
