//
//  WSCaptureController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSModalityMap.h"
#import "WSCaptureButton.h"
#import "constants.h"

@protocol WSCaptureDelegate <NSObject>

//-(void) didRequestModalityChangeForItem:(WSCDItem*)item;
//-(void) didRequestDeviceChangeForItem:(WSCDItem*)item;

@end

@interface WSCaptureController : UIViewController

-(IBAction)modalityButtonPressed:(id)sender;
-(IBAction)deviceButtonPressed:(id)sender;
-(IBAction)captureButtonPressed:(id)sender;

@property (nonatomic, strong) UIPopoverController *popoverController;

@property (nonatomic, strong) WSCDItem *item;
@property (nonatomic, strong) IBOutlet UIButton *modalityButton;
@property (nonatomic, strong) IBOutlet UIButton *deviceButton;
@property (nonatomic, strong) IBOutlet UIImageView *itemDataView;
@property (nonatomic, strong) IBOutlet WSCaptureButton *captureButton;

@property (nonatomic, unsafe_unretained) id<WSCaptureDelegate> delegate;

@end
