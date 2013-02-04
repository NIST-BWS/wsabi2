//
//  WSDeviceChooserController.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

#import <UIKit/UIKit.h>
#import "BWSConstants.h"
#import "NSManagedObject+DeepCopy.h"
#import "BWSModalityMap.h"
#import "WSCDItem.h"
#import "WSDeviceSetupController.h"

#define NUM_RECENT_SENSORS 5

@interface BWSDeviceChooserController : UITableViewController
{
    NSMutableArray *recentSensors;
}

-(IBAction) tappedBehindView:(id)sender;
-(IBAction) currentButtonPressed:(id)sender;

@property (nonatomic) BOOL autodiscoveryEnabled;
@property (nonatomic) WSSensorCaptureType submodality;
@property (nonatomic) WSSensorModalityType modality;

@property (nonatomic, strong) WSCDItem *item;
@property (nonatomic, strong) UIBarButtonItem *currentButton;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapBehindViewRecognizer;

@end
