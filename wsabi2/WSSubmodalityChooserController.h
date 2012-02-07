//
//  WSSubmodalityChooser.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSModalityMap.h"
#import "WSDeviceChooserController.h"

@interface WSSubmodalityChooserController : UITableViewController
{
    NSArray *submodalities;
}

@property (nonatomic) WSSensorModalityType modality;
@property (nonatomic, strong) WSCDItem *item;

@end
