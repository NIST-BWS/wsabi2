//
//  WSViewController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "WSCDPerson.h"
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSDeviceConfigDelegate.h"
#import "WSPersonTableViewCell.h"
#import "WSModalityChooserController.h"

#import "NBCLSensorLink.h"
#import "NBCLSensorLinkConstants.h"

@interface WSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,
                                                UIPopoverControllerDelegate,
                                                WSPersonTableViewCellDelegate, WSDeviceConfigDelegate, 
                                                NSFetchedResultsControllerDelegate>
{
    NSIndexPath *selectedIndex;
    NSMutableDictionary *sensorLinks;
    NSIndexPath *previousSelectedIndex;
}

-(void) presentSensorWalkthrough:(NSNotification*)notification;
-(void) didHideSensorWalkthrough:(NSNotification*)notification;
-(void) startItemCapture:(NSNotification*)notification;
-(void) stopItemCapture:(NSNotification*)notification;

-(IBAction)addFirstButtonPressed:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *popoverController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *addFirstButton;

@end
