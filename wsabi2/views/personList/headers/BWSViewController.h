// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "BWSCDPerson.h"
#import "BWSCDItem.h"
#import "BWSCDDeviceDefinition.h"
#import "BWSPersonTableViewCell.h"
#import "BWSModalityChooserController.h"
#import "BWSPopoverBackgroundView.h"

#import "BWSDeviceLinkConstants.h"

@interface BWSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
UIPopoverControllerDelegate,
BWSPersonTableViewCellDelegate,
NSFetchedResultsControllerDelegate>
{
    NSIndexPath *selectedIndex;
    NSMutableDictionary *sensorLinks;
    NSIndexPath *previousSelectedIndex;
    
    BOOL shouldRestoreCapturePopover;
    
    BWSCDPerson* personBeingEdited;
    BOOL wasAnnotating;
    BOOL wasLightboxing;
    BOOL wasBiographing;
    BOOL keyboardShown;
}

-(void) presentSensorWalkthrough:(NSNotification*)notification;
-(void) didCompleteSensorWalkthrough:(NSNotification*)notification;
-(void) didCancelSensorWalkthrough:(NSNotification*)notification;

-(void) startItemCapture:(NSNotification*)notification;
-(void) stopItemCapture:(NSNotification*)notification;

-(IBAction)addFirstButtonPressed:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *popoverController;

@property (strong, nonatomic) IBOutlet UIImageView *dropShadowView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *addFirstButton;

@end
