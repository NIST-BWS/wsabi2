//
//  WSDeviceSetupController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDDeviceDefinition.h"
#import "WSCDItem.h"
#import "ELCTextfieldCellWide.h"

@interface WSDeviceSetupController : UITableViewController


-(IBAction)doneButtonPressed:(id)sender;

@property (nonatomic, strong) WSCDItem *item;
@property (nonatomic, strong) WSCDDeviceDefinition *deviceDefinition;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderCustomView;
@end
