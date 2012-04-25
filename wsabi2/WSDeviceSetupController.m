//
//  WSDeviceSetupController.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSDeviceSetupController.h"
#import "WSAppDelegate.h"

#define STATUS_CONTAINER_HEIGHT 95

@implementation WSDeviceSetupController

@synthesize item;
@synthesize deviceDefinition;
@synthesize modality;
@synthesize submodality;

//Status stuff
@synthesize sensorCheckStatus;

@synthesize statusContainer;
@synthesize statusContainerBackgroundView;
@synthesize statusTextButton;

@synthesize notFoundContainer;
@synthesize reconnectButton;

@synthesize warningContainer;
@synthesize editAddressButton;
@synthesize changeCaptureTypeButton;

@synthesize checkingContainer;
@synthesize checkingActivity;
@synthesize checkingLabel;

//Table view stuff
@synthesize tableView;

@synthesize walkthroughDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if (self.deviceDefinition && self.deviceDefinition.name) {
        self.title = self.deviceDefinition.name;
    }
    else {
        self.title = @"New Sensor";
    }

    self.statusContainerBackgroundView.image = [[UIImage imageNamed:@"InsetGrayBackground"] stretchableImageWithLeftCapWidth:5 topCapHeight:33];
    
    //configure button images
    [self.reconnectButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBlue"] stretchableImageWithLeftCapWidth:3 topCapHeight:0]
                                    forState:UIControlStateNormal];
    [self.reconnectButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBluePressed"] stretchableImageWithLeftCapWidth:3 topCapHeight:0]
                                forState:UIControlStateHighlighted];
    
    [self.editAddressButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBlue"] stretchableImageWithLeftCapWidth:3 topCapHeight:0]
                                    forState:UIControlStateNormal];
    [self.editAddressButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBluePressed"] stretchableImageWithLeftCapWidth:3 topCapHeight:0]
                                    forState:UIControlStateHighlighted];
    
    [self.changeCaptureTypeButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBlue"] stretchableImageWithLeftCapWidth:3 topCapHeight:0]
                                    forState:UIControlStateNormal];
    [self.changeCaptureTypeButton setBackgroundImage:[[UIImage imageNamed:@"PurchaseButtonBluePressed"] stretchableImageWithLeftCapWidth:3 topCapHeight:0]
                                    forState:UIControlStateHighlighted];
    
    
    //Add a gesture recognizer to dismiss the keyboard when tapping the table background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    //enable touch logging for this controller
    [self.view startAutomaticGestureLogging:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Property Getters/Setters
-(void) setSensorCheckStatus:(WSSensorSetupStatusType)newStatus
{
    sensorCheckStatus = newStatus;
        
    //Update the UI to match the current status.
    //Animate the change.
    [UIView animateWithDuration:kMediumFadeAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.navigationItem.rightBarButtonItem.enabled = NO; //start with the Done button disabled.
                         switch (sensorCheckStatus) {
                             case kStatusBlank:
                                 //hide everything.
                                 [self.statusTextButton setTitle:@"Enter a sensor address below." forState:UIControlStateNormal];
                                 self.statusTextButton.enabled = NO; //use the disabled state, which is the not-found state.
                                 self.statusTextButton.selected = NO;
                                 self.statusTextButton.alpha = 1.0;
                                 self.checkingContainer.alpha = 0.0;
                                 self.notFoundContainer.alpha = 0.0;
                                 self.warningContainer.alpha = 0.0;
                                 break;
                             case kStatusChecking:
                                 self.statusTextButton.alpha = 0.0;
                                 self.checkingContainer.alpha = 1.0;
                                 self.notFoundContainer.alpha = 0.0;
                                 self.warningContainer.alpha = 0.0;
                                 break;
                             case kStatusNotFound:
                                 self.navigationItem.rightBarButtonItem.enabled = YES; //enable this, but we need to prompt the user in this case.
                                 self.statusTextButton.alpha = 1.0;
                                 [self.statusTextButton setTitle:@"No sensor found at this address." forState:UIControlStateNormal];
                                 self.statusTextButton.enabled = NO; //use the disabled state, which is the not-found state.
                                 self.statusTextButton.selected = NO;
                                 
                                 self.checkingContainer.alpha = 0.0;
                                 self.notFoundContainer.alpha = 1.0;
                                 self.warningContainer.alpha = 0.0;
                                 break;
                             case kStatusBadModality:
                                 self.statusTextButton.alpha = 1.0;
                                 [self.statusTextButton setTitle:
                                  [NSString stringWithFormat:@"The sensor at this address can't capture %@ data.", [[WSModalityMap stringForModality:self.modality] lowercaseString]]
                                                        forState:UIControlStateNormal];
                                 self.statusTextButton.enabled = YES;
                                 self.statusTextButton.selected = NO; //use the deselected state, which is the warning state.

                                 self.checkingContainer.alpha = 0.0;
                                 self.notFoundContainer.alpha = 0.0;
                                 self.warningContainer.alpha = 1.0;
                                 break;
                             case kStatusBadSubmodality:
                                 self.statusTextButton.alpha = 1.0;
                                 [self.statusTextButton setTitle:
                                  [NSString stringWithFormat:@"The sensor at this address can't capture %@ data.", [[WSModalityMap stringForCaptureType:self.submodality] lowercaseString]]
                                                        forState:UIControlStateNormal];
                                 self.statusTextButton.enabled = YES;
                                 self.statusTextButton.selected = NO; //use the deselected state, which is the warning state.

                                 self.checkingContainer.alpha = 0.0;
                                 self.notFoundContainer.alpha = 0.0;
                                 self.warningContainer.alpha = 1.0;
                                 break;
                             case kStatusSuccessful:
                                 self.navigationItem.rightBarButtonItem.enabled = YES;
                                 self.statusTextButton.alpha = 1.0;
                                 [self.statusTextButton setTitle:@"Found a sensor at this address." forState:UIControlStateNormal];
                                 self.statusTextButton.enabled = YES;
                                 self.statusTextButton.selected = YES; //use the selected state, which is the OK state.

                                 self.checkingContainer.alpha = 0.0;
                                 self.notFoundContainer.alpha = 0.0;
                                 self.warningContainer.alpha = 0.0;

                                 break;
                                 
                             default:
                                 //No changes.
                                 break;
                         }

//                         //update the table size
//                         self.tableView.frame = (sensorCheckStatus == kStatusBlank) ? 
//                         CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) :
//                         CGRectMake(0, STATUS_CONTAINER_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - STATUS_CONTAINER_HEIGHT) ;

                     }
                     completion:^(BOOL completed) {
                         
                     }
     ];
}

#pragma mark - Button action methods
-(IBAction)doneButtonPressed:(id)sender
{
    
    //Store the device definition in the item at this point.
    self.item.modality = [WSModalityMap stringForModality:self.modality];
    self.item.submodality = [WSModalityMap stringForCaptureType:self.submodality];
    
    //If necessary, insert both the item and its device definition into the real context, which
    //we'll have to get from the app delegate.
    NSManagedObjectContext *moc = [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];

    if (!self.item.managedObjectContext) {
        [moc insertObject:self.item];
    }
    if (!self.deviceDefinition.managedObjectContext) {
        [moc insertObject:self.deviceDefinition];
    }
    
    //connect the device definition and the item.
    self.item.deviceConfig = self.deviceDefinition;
    
    
    
    [self dismissModalViewControllerAnimated:YES];
    
    //post a notification to hide the device chooser and return to the previous state
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:item forKey:kDictKeyTargetItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCompleteWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];
    
}

-(IBAction)cycleButtonPressed:(id)sender
{
    if (self.sensorCheckStatus < (kStatus_COUNT - 1)) {
        self.sensorCheckStatus += 1;
    }
    else
        self.sensorCheckStatus = 0;
}

-(IBAction)checkAgainButtonPressed:(id)sender
{
    //set the status back to checking.
    self.sensorCheckStatus = kStatusChecking;
}

-(IBAction)editAddressButtonPressed:(id)sender;
{
    //find the network address field and make it first responder.
    ELCTextfieldCellWide *addressCell = (ELCTextfieldCellWide*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (addressCell) {
        [addressCell.rightTextField becomeFirstResponder];
    }
}

-(IBAction)changeCaptureTypeButtonPressed:(id)sender
{
    if (self.sensorCheckStatus == kStatusBadModality) {
        //pop back to the modality chooser.
        //find it first.
        WSModalityChooserController *target = nil;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[WSModalityChooserController class]]) {
                target = (WSModalityChooserController*) vc;
            }
        }
        if (target) {
            [self.navigationController popToViewController:target animated:YES];
        }
    }
    else if (self.sensorCheckStatus == kStatusBadSubmodality) {
        //pop back to the submodality chooser.
        //find it first.
        WSSubmodalityChooserController *target = nil;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[WSSubmodalityChooserController class]]) {
                target = (WSSubmodalityChooserController*) vc;
            }
        }
        if (target) {
            [self.navigationController popToViewController:target animated:YES];
        }

    }
}

-(void) dismissKeyboard:(UITapGestureRecognizer*)recog
{
    //find any active text field and make it resign the keyboard.
    for (UITableViewCell *c in self.tableView.subviews) {
        if ([c isKindOfClass:[ELCTextfieldCell class]]) {
            [((ELCTextfieldCell*)c).rightTextField resignFirstResponder];
        }
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return 2; //name and address
            break;
        case 1:
            return 0; //FIXME: This should return the parameter count.
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StringCell = @"StringCell";
    static NSString *OtherCell = @"OtherCell";
    
    if (indexPath.section == 0) {
        //basic info section
        ELCTextfieldCellWide *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
        if (cell == nil) {
            cell = [[ELCTextfieldCellWide alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
            //enable touch logging for new cells
            [cell startAutomaticGestureLogging:YES];
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        //Disables UITableViewCell from accidentally becoming selected.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.leftLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.rightTextField.font = [UIFont systemFontOfSize:15];
        cell.rightTextField.placeholder = @"";
        
        if (indexPath.row == 0) {
            cell.leftLabel.text = @"Network Address";
            if (self.deviceDefinition) {
                cell.rightTextField.text = self.deviceDefinition.uri;
            }
            cell.rightTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.rightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        else if (indexPath.row == 1) {
            cell.leftLabel.text = @"Name";
            if (self.deviceDefinition) {
                cell.rightTextField.text = self.deviceDefinition.name;
            }
        }
        return cell;
        
    }
    else {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:OtherCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OtherCell];
            //enable touch logging for new cells
            [cell startAutomaticGestureLogging:YES];
        }
        
        // Configure the cell...
        
        return cell;
        
    }    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark ELCTextFieldCellDelegate Methods

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
    
    //	if(indexPath.row < [labels count]-1) {
    //		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    //		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
    //		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //	}
    //	
    //	else {
    //        
    //		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
    //	}
}

- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string {
    
	//NSLog(@"See input: %@ from section: %d row: %d, should update models appropriately", string, indexPath.section, indexPath.row);
    
    if (indexPath.section == 0) {
        //These are all string cells
        if (indexPath.row == 0) {
            //update the uri
            if(self.deviceDefinition) self.deviceDefinition.uri = string;
        }
        else if (indexPath.row == 1) {
            //update the name and the window title.
            self.title = string;
            if(self.deviceDefinition) self.deviceDefinition.name = string;
        }
    }
}

@end
