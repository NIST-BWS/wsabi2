//
//  WSViewController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/10/12.

//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "WSCDPerson.h"
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
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
    
    WSCDPerson* personBeingEdited;
    BOOL wasAnnotating;
    BOOL wasLightboxing;
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
