// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import "BWSConstants.h"
#import "NSManagedObject+DeepCopy.h"
#import "BWSModalityMap.h"
#import "BWSCDItem.h"
#import "BWSDeviceSetupController.h"

#define NUM_RECENT_SENSORS 5

@interface BWSDeviceChooserController : UITableViewController
{
    NSMutableArray *recentSensors;
}

-(IBAction) currentButtonPressed:(id)sender;

@property (nonatomic) BOOL autodiscoveryEnabled;
@property (nonatomic) WSSensorCaptureType submodality;
@property (nonatomic) WSSensorModalityType modality;

@property (nonatomic, strong) BWSCDItem *item;
@property (nonatomic, strong) UIBarButtonItem *currentButton;

@end
