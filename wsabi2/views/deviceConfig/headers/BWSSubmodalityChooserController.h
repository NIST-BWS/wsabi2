// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import "BWSCDItem.h"
#import "BWSCDDeviceDefinition.h"
#import "BWSModalityMap.h"
#import "BWSDeviceChooserController.h"

@interface BWSSubmodalityChooserController : UITableViewController
{
    NSArray *submodalities;
}

-(IBAction) currentButtonPressed:(id)sender;

@property (nonatomic) WSSensorModalityType modality;
@property (nonatomic, strong) BWSCDItem *item;
@property (nonatomic, strong) UIBarButtonItem *currentButton;

@end
