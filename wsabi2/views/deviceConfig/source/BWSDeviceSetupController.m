// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSDeviceSetupController.h"
#import "BWSAppDelegate.h"

#define STATUS_CONTAINER_HEIGHT 95

#define TAG_NETWORK_ADDRESS 1000
#define TAG_NAME 1001

@implementation BWSDeviceSetupController

@synthesize item;
@synthesize deviceDefinition;
@synthesize modality;
@synthesize submodality;
@synthesize tapBehindViewRecognizer;

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
        
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if (self.deviceDefinition && self.deviceDefinition.name) {
        self.title = self.deviceDefinition.name;
    }
    else {
        self.title = @"New Sensor";
    }
    [self.view setAccessibilityLabel:@"Device Walkthrough -- Sensor Properties"];

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
    
    
    //Set up the basic sensor link.
    if (self.deviceDefinition && self.deviceDefinition.uri) {
        self.sensorCheckStatus = kStatusChecking;
        //Start checking this sensor right away.
        sensorCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                            target:self
                                                          selector:@selector(checkSensor:) userInfo:self.deviceDefinition.uri
                                                           repeats:NO];
    }
    else {
        //Start with a blank status section by default
        self.sensorCheckStatus = kStatusBlank;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Add recognizer to detect taps outside of the modal view
    [[self tapBehindViewRecognizer] setCancelsTouchesInView:NO];
    [[self tapBehindViewRecognizer] setNumberOfTapsRequired:1];
    [[[self view] window] addGestureRecognizer:[self tapBehindViewRecognizer]];
    
    [self.view logViewPresented];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeScroll];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //work around a bug in iOS – adding a white activity indicator in Interface Builder, the indicator doesn't stay
    //white.
    self.checkingActivity.color = [UIColor whiteColor];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //disconnect the sensor link's delegate in case any long-running operations
    //come through later.
    currentLink.delegate = nil;

    //whatever the reason for disappearing, cancel all of our network operations
    [currentLink cancelAllOperations];    
    
    // Remove recognizer when view isn't visible
    [[[self view] window] removeGestureRecognizer:[self tapBehindViewRecognizer]];
    
    if ([sensorCheckTimer isValid])
        [sensorCheckTimer invalidate];
        
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view logViewDismissed];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];

    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setTapBehindViewRecognizer:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)tappedBehindView:(id)sender
{
    UITapGestureRecognizer *recognizer = (UITapGestureRecognizer *)sender;
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // Get coordinates in the window of tap
        CGPoint location = [recognizer locationInView:nil];
        
        // Check if tap was within view
        if (![self.navigationController.view pointInside:[self.navigationController.view convertPoint:location fromView:self.view.window] withEvent:nil]) {
            [[[self view] window] removeGestureRecognizer:[self tapBehindViewRecognizer]];
            
            // Show popover controller that was hidden
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:item forKey:kDictKeyTargetItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCancelWalkthroughNotification
                                                                object:self
                                                              userInfo:userInfo];
            
            [self.view logViewDismissedViaTapAtPoint:location];
            [self dismissModalViewControllerAnimated:YES];
        }
    }
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
                                  [NSString stringWithFormat:@"The sensor at this address can't capture %@ data.", [[BWSModalityMap stringForModality:self.modality] lowercaseString]]
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
                                  [NSString stringWithFormat:@"The sensor at this address can't capture %@ data.", [[BWSModalityMap stringForCaptureType:self.submodality] lowercaseString]]
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

                     }
                     completion:^(BOOL completed) {
                         
                     }
     ];
}

#pragma mark - Button action methods
-(IBAction)doneButtonPressed:(id)sender
{
    
    //Store the device definition in the item at this point.
    self.item.modality = [BWSModalityMap stringForModality:self.modality];
    self.item.submodality = [BWSModalityMap stringForCaptureType:self.submodality];
    
    NSLog(@"About to store an item with modality %@ and submodality %@",[BWSModalityMap stringForModality:self.modality],[BWSModalityMap stringForCaptureType:self.submodality]);
    
    UITextField *networkField = (UITextField*)[self.tableView viewWithTag:TAG_NETWORK_ADDRESS];
    self.deviceDefinition.uri = networkField.text;
    UITextField *nameField = (UITextField*)[self.tableView viewWithTag:TAG_NAME];
    self.deviceDefinition.name = nameField.text;

    //For the moment, just set the device definition's modalities and submodalities strings
    //to the current modality and submodality. This could be expanded for multiple modalities later.
    self.deviceDefinition.modalities = self.item.modality;
    self.deviceDefinition.submodalities = self.item.submodality;

    //also store these in the parameter dictionary (this is probably something that should be resolved rather than duplicated)
    //NOTE: This uses the parameter form of the submodality, rather than the pretty-printed form.
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setObject:self.item.modality forKey:@"modality"];
    [params setObject:[BWSModalityMap parameterNameForCaptureType:self.submodality] forKey:@"submodality"];
    self.deviceDefinition.parameterDictionary = [NSKeyedArchiver archivedDataWithRootObject:params];
    
    //If necessary, insert both the item and its device definition into the real context, which
    //we'll have to get from the app delegate.
    NSManagedObjectContext *moc = [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];

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
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.item forKey:kDictKeyTargetItem];
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
    //fire an action to query the sensor about status.
    
    //If the timer is already running, cancel it.
    if (sensorCheckTimer.isValid) {
        [sensorCheckTimer invalidate];
        //update the UI
        self.sensorCheckStatus = kStatusBlank;
    }
    
    //start a new scheduled timer to fire a sensor check in 0.05 seconds.

    //find the network address field
    ELCTextFieldCellWide *addressCell = (ELCTextFieldCellWide*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *newUri = addressCell.rightTextField.text;
    
    sensorCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                        target:self
                                                      selector:@selector(checkSensor:) userInfo:newUri
                                                       repeats:NO];
}

-(IBAction)editAddressButtonPressed:(id)sender;
{
    //find the network address field and make it first responder.
    ELCTextFieldCellWide *addressCell = (ELCTextFieldCellWide*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (addressCell) {
        [addressCell.rightTextField becomeFirstResponder];
    }
}

-(IBAction)changeCaptureTypeButtonPressed:(id)sender
{
    if (self.sensorCheckStatus == kStatusBadModality) {
        //pop back to the modality chooser.
        //find it first.
        BWSModalityChooserController *target = nil;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[BWSModalityChooserController class]]) {
                target = (BWSModalityChooserController*) vc;
            }
        }
        if (target) {
            [self.navigationController popToViewController:target animated:YES];
        }
        else {
            //We're trying to back up further than we've loaded. Add the full navigation stack.
            [self dismissViewControllerAnimated:YES completion:^{
                //Post a notification to show the modality walkthrough starting from device selection.
                NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item,kDictKeyTargetItem,[NSNumber numberWithBool:NO],kDictKeyStartFromDevice,nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                                    object:self
                                                                  userInfo:userInfo];
            }];
 

        }
    }
    else if (self.sensorCheckStatus == kStatusBadSubmodality) {
        //pop back to the submodality chooser.
        //find it first.
        BWSSubmodalityChooserController *target = nil;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[BWSSubmodalityChooserController class]]) {
                target = (BWSSubmodalityChooserController*) vc;
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
        if ([c isKindOfClass:[ELCTextFieldCellWide class]]) {
            [((ELCTextFieldCellWide*)c).rightTextField resignFirstResponder];
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
        ELCTextFieldCellWide *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
        if (cell == nil) {
            cell = [[ELCTextFieldCellWide alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        //Disables UITableViewCell from accidentally becoming selected.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        
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
            cell.rightTextField.keyboardType = UIKeyboardTypeURL;
            cell.rightTextField.tag = TAG_NETWORK_ADDRESS;
        }
        else if (indexPath.row == 1) {
            cell.leftLabel.text = @"Name";
            if (self.deviceDefinition) {
                cell.rightTextField.text = self.deviceDefinition.name;
                cell.rightTextField.tag = TAG_NAME;
                cell.rightTextField.keyboardType = UIKeyboardTypeAlphabet;
            }
        }
        
        cell.rightTextField.delegate = self;
        cell.accessibilityLabel = cell.leftLabel.text;
        cell.rightTextField.accessibilityLabel = cell.accessibilityLabel;
        [[cell rightTextField] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        return cell;
    }
    else {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:OtherCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OtherCell];
        }
        
        // Configure the cell...
        [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        cell.accessibilityLabel = cell.textLabel.text;
        return cell;
    }    
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==  UITableViewCellEditingStyleDelete)
        [[aTableView cellForRowAtIndexPath:indexPath] stopLoggingBWSInterfaceEvents];
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Bring insertion point to text field when cell is tapped
	ELCTextFieldCellWide *cell = (ELCTextFieldCellWide *)[aTableView cellForRowAtIndexPath:indexPath];
	if (cell != nil)
		[cell.rightTextField becomeFirstResponder];
}

#pragma mark ELCTextfieldCellWideDelegate Methods

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
    
    //	if(indexPath.row < [labels count]-1) {
    //		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    //		[[(ELCTextfieldCellWide*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
    //		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //	}
    //	
    //	else {
    //        
    //		[[(ELCTextfieldCellWide*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
    //	}
}

- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string {
    
//	//NSLog(@"See input: %@ from section: %d row: %d, should update models appropriately", string, indexPath.section, indexPath.row);
//    
//    if (indexPath.section == 0) {
//        //These are all string cells
//        if (indexPath.row == 0) {
//            //update the uri
//            if(self.deviceDefinition) self.deviceDefinition.uri = string;
//        }
//        else if (indexPath.row == 1) {
//            //update the name and the window title.
//            self.title = string;
//            if(self.deviceDefinition) self.deviceDefinition.name = string;
//        }
//    }
}

#pragma mark - UITextField Delegate methods
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //allow the text change, and fire a delayed action to query the sensor about status.
    
    //If the timer is already running, cancel it.
    if (sensorCheckTimer.isValid) {
        [sensorCheckTimer invalidate];
        //update the UI
        self.sensorCheckStatus = kStatusBlank;
    }
    
    //start a new scheduled timer to fire a sensor check in 3 seconds.
    NSString *newUri = [textField.text stringByReplacingCharactersInRange:range withString:string];
    sensorCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                        target:self
                                                      selector:@selector(checkSensor:) userInfo:newUri
                                                       repeats:NO];
        
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField logTextEntryBegan];
    
    // Apple removes gesture recognizers when becoming first responder
    [textField startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [textField logTextEntryEnded];
    [textField resignFirstResponder];
    
    // Apple removes gesture recognizers when resigning first responder
    [textField startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
}

#pragma mark - Sensor interaction stuff
-(void) checkSensor:(NSTimer*)timer
{
    if (checkingSensor) {
        //we're currently in the middle of a check. Cancel it, and start
        //a new check.
        //NOTE: We don't care about the return result, so just cancel this op from the client.
        [currentLink cancelAllOperations];
    }
    
    NSLog(@"checkSensor gets incoming object %@",(NSString*)timer.userInfo);
    
    // Don't pass a nil string to BaseURI
    if ((timer.userInfo == nil) || [(NSString *)timer.userInfo isEqualToString:@""])
        return;
    BWSDeviceLink *deviceLink = [[BWSDeviceLink alloc] initWithBaseURI:(NSString*)timer.userInfo];
    deviceLink.delegate = self;
    
    //start the metadata call (we're passing our WSCDItem here, but it's mainly
    //to make sure we don't pass a nil object; at the moment, nothing is done with it.)
    self.sensorCheckStatus = kStatusChecking;
    
    checkingSensor = YES;
    [deviceLink getServiceInfo:[self.item.objectID URIRepresentation]];
    currentLink = deviceLink;
}

#pragma mark - Device link delegate
-(void) sensorOperationDidFail:(SensorOperationType)opType fromLink:(BWSDeviceLink*)link deviceID:(NSURL*)deviceID withError:(NSError*)error
{
    //we couldn't get hold of the sensor info we expected; set status accordingly.
    self.sensorCheckStatus = kStatusNotFound;
    checkingSensor = NO;
}

-(void) sensorOperationWasCancelledByService:(SensorOperationType)opType fromLink:(BWSDeviceLink*)link deviceID:(NSURL*)deviceID withResult:(WSBDResult*)result
{
    //we couldn't get hold of the sensor info we expected; set status accordingly.
    self.sensorCheckStatus = kStatusNotFound;
    checkingSensor = NO;
}

-(void) sensorOperationCompleted:(SensorOperationType)opType fromLink:(BWSDeviceLink*)link deviceID:(NSURL*)deviceID withResult:(WSBDResult*)result
{
    if (!result || result.status != StatusSuccess || !result.metadata) {
        //we didn't get a result back, or it didn't give us a metadata dictionary at all.
        //Since there aren't any parameters to change, treat this as a failure.
        self.sensorCheckStatus = kStatusNotFound;
        return;
    }
    
    NSMutableDictionary *serviceMetadata = result.metadata;

    NSLog(@"Service metadata is %@ of class %@",result.metadata.description, [result.metadata class]);
    
    //These parameters are described in Appendix A of NIST SP 500-288
    NSLog(@"Modality param is actually of class %@",[[serviceMetadata objectForKey:@"modality"] class]);
    WSBDParameter *serviceModalityParam = [serviceMetadata objectForKey:@"modality"];
    WSBDParameter *serviceSubmodalityParam = [serviceMetadata objectForKey:@"submodality"];
    BOOL isSensorOperationCompleted = false;
    
    //Check modality
    if (serviceModalityParam.readOnly) {
        NSString *serviceModalityDefault = serviceModalityParam.defaultValue;
        
        if([serviceModalityDefault localizedCaseInsensitiveCompare:
            [BWSModalityMap stringForModality:self.modality]] 
           != NSOrderedSame)
        {
            //This sensor doesn't support the requested modality. operation complete.
            self.sensorCheckStatus = kStatusBadModality;
            NSLog(@"Expected modality %@, got %@",[BWSModalityMap stringForModality:self.modality],
                  serviceModalityDefault);
            isSensorOperationCompleted = true;
        }
        else {
            //We're good. Continue to check submodality
            self.sensorCheckStatus = kStatusSuccessful;
        }

    }
    else {
        //This has to look at allowedValues, not defaultValue!!
        NSArray *serviceModalityAllowed = serviceModalityParam.allowedValues;
        
        BOOL modalityOK = NO;
        for (NSString *mod in serviceModalityAllowed) {
            NSLog(@"Expected modality %@, got %@",[BWSModalityMap stringForModality:self.modality],
                  mod);

            if ([mod localizedCaseInsensitiveCompare:
                 [BWSModalityMap stringForModality:self.modality]] 
                == NSOrderedSame)
            {
                modalityOK = YES;
                break; //we found something, no need to continue.
            }
        }
        
        if (!modalityOK) {
            //This sensor doesn't support the requested modality.
            self.sensorCheckStatus = kStatusBadModality;
            isSensorOperationCompleted = true;
        }
        
    }
    
    if (!isSensorOperationCompleted){
        //Check submodality
        if (serviceSubmodalityParam.readOnly) {
            NSString *serviceSubmodalityDefault = serviceSubmodalityParam.defaultValue;
            
            if([serviceSubmodalityDefault localizedCaseInsensitiveCompare:
                [BWSModalityMap parameterNameForCaptureType:self.submodality]] 
               != NSOrderedSame)
            {
                //This sensor doesn't support the requested submodality.
                self.sensorCheckStatus = kStatusBadSubmodality;
                NSLog(@"Expected submodality %@, got %@",[BWSModalityMap parameterNameForCaptureType:self.submodality], serviceSubmodalityDefault);
            }
            else {
                //We're good.
                self.sensorCheckStatus = kStatusSuccessful;
            }
            
        }
        else {
            //This has to look at allowedValues, not defaultValue!!
            NSArray *serviceSubmodalityAllowed = serviceSubmodalityParam.allowedValues;
            
            BOOL submodalityOK = NO;
            for (NSString *smod in serviceSubmodalityAllowed) {
                NSLog(@"Expected submodality %@, got %@", [BWSModalityMap parameterNameForCaptureType:self.submodality], smod);
                if ([smod localizedCaseInsensitiveCompare:
                     [BWSModalityMap parameterNameForCaptureType:self.submodality]] 
                    == NSOrderedSame)
                {
                    submodalityOK = YES;
                    break; //we found something, no need to continue.
                }
            }
            
            if (!submodalityOK) {
                //This sensor doesn't support the requested modality.
                self.sensorCheckStatus = kStatusBadSubmodality;
            }
            else {
                //We're good.
                self.sensorCheckStatus = kStatusSuccessful;
            }
            
        }    
    }


    checkingSensor = NO; //done checking.


}

@end
