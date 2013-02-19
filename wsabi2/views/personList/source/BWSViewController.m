// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSViewController.h"

#import "BWSAppDelegate.h"
#import "NSManagedObject+DeepCopy.h"
#import "BWSSettingsViewController.h"
#import "BWSDDLog.h"

@implementation BWSViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize popoverController;
@synthesize tableView;
@synthesize dropShadowView;
@synthesize addFirstButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    keyboardShown = NO;

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //set the table view background
    //self.tableView.backgroundColor = [UIColor grayColor]; //[UIColor colorWithPatternImage:[UIImage imageNamed:@"square_bg"]];
    
    //Set up the nav bar.
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:32/255.0 green:32/255.0 blue:32/255.0 alpha:1.0]];
    
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wsabi-title"]];
    self.navigationItem.titleView = titleView;
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTitleVerticalPositionAdjustment:-4 forBarMetrics:UIBarMetricsDefault];
    
    self.dropShadowView.image = [[UIImage imageNamed:@"cell-drop-shadow-down"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    
    //initialize the popover controller that we're going to use for everything (use a dummy view controller to start)
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:[[UIViewController alloc] init]];
    self.popoverController.popoverBackgroundViewClass = [BWSPopoverBackgroundView class];
    self.popoverController.delegate = self;
    
    self.fetchedResultsController.delegate = self;
    
    //add a drop shadow to the add button
    self.addFirstButton.alpha = [self.fetchedResultsController.fetchedObjects count] > 0 ? 0.0 : 1.0;
    
    self.addFirstButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.addFirstButton.layer.shadowOffset = CGSizeMake(0,4);
    self.addFirstButton.layer.shadowOpacity = 0.7;
    self.addFirstButton.layer.shadowRadius = 10;
    
    //initialize the sensor link dictionary, which will connect WSCDItems to sensor link objects.
    sensorLinks = [[NSMutableDictionary alloc] init];
    
    //Add notification listeners for global actions we want to catch
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentSensorWalkthrough:)
                                                 name:kShowWalkthroughNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCompleteSensorWalkthrough:)
                                                 name:kCompleteWalkthroughNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCancelSensorWalkthrough:)
                                                 name:kCancelWalkthroughNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startItemCapture:)
                                                 name:kStartCaptureNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopItemCapture:)
                                                 name:kStopCaptureNotification
                                               object:nil];
    [[self tableView] setAccessibilityLabel:@"Person List"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self addFirstButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeScroll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[self tableView] stopLoggingBWSInterfaceEvents];
    [[self addFirstButton] stopLoggingBWSInterfaceEvents];
    [[self tableView] stopLoggingBWSInterfaceEvents];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Don't allow rotation if a lightbox is being displayed, since the rotation
    // will trigger the popover to close, and the popover is the lightbox's
    // presentingViewController.
    BWSPersonTableViewCell *cell = (BWSPersonTableViewCell *)[[self tableView] cellForRowAtIndexPath:[[self tableView] indexPathForSelectedRow]];
    if ((cell == nil) || ([cell selectedIndex] == -1))
        return (YES);
        
    if ([[cell captureController] isLightboxing])
        return (NO);

    return (YES);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Record if the flip side of the CaptureController is presently shown
    BWSPersonTableViewCell *cell = (BWSPersonTableViewCell *)[[self tableView] cellForRowAtIndexPath:[[self tableView] indexPathForSelectedRow]];
    wasAnnotating = ((cell != nil) && ([cell selectedIndex] != -1) && ([[cell captureController] isAnnotating] == YES));
    wasLightboxing = ((cell != nil) && ([cell selectedIndex] != -1) && ([[cell captureController] isLightboxing] == YES));
    wasBiographing = ((cell != nil) && [cell biographicalDataVisible]);

    if (wasBiographing)
        [cell dismissBiographicalPopover];
    
    // Scroll the row into visibility
    if ([[self tableView] indexPathForSelectedRow] != nil)
        [[self tableView] scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // Remove keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // Redisplay capture controller if it was visible
    BWSPersonTableViewCell *cell = (BWSPersonTableViewCell *)[[self tableView] cellForRowAtIndexPath:[[self tableView] indexPathForSelectedRow]];
    if ((cell != nil) && ([cell selectedIndex] != -1)) {
        [cell showCapturePopoverAtIndex:[cell selectedIndex]];
        if (wasAnnotating)
            [[cell captureController] showFlipSideAnimated:NO];
        if (wasLightboxing)
            [[cell captureController] showLightbox];
    }
    if (wasBiographing)
        [cell biographicalDataButtonPressed:cell.biographicalDataButton];
    
    // Delay adding keyboard notifiers until keyboard has 
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
    });
}

#pragma mark - Notification action methods
-(void) presentSensorWalkthrough:(NSNotification*)notification
{
    //start by deselecting everything in the current row.
    BWSPersonTableViewCell *row = (BWSPersonTableViewCell*) [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [row selectItem:nil];
    
    BWSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];
    
    //figure out whether we should restore the capture popover later.
    //NOTE: do so unless we came from the add-new-item button.
    shouldRestoreCapturePopover = (item.managedObjectContext != nil);
    
    // Start from device
    if ([[notification.userInfo objectForKey:kDictKeyStartFromDevice] boolValue]) {
        //only show the walkthrough from device selection onwards.
        BWSDeviceChooserController *chooser = [[BWSDeviceChooserController alloc] initWithNibName:@"BWSDeviceChooserController" bundle:nil];
        chooser.item = item;
        
        //FIXME: Set the modality/submodality either here or in the chooser automatically
        chooser.modality = [BWSModalityMap modalityForString:item.modality];
        chooser.submodality = [BWSModalityMap captureTypeForString:item.submodality];
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigation animated:YES completion:NULL];
        // Start from submodality
    } else if ([[notification.userInfo objectForKey:kDictKeyStartFromSubmodality] boolValue]) {
        BWSSubmodalityChooserController *chooser = [[BWSSubmodalityChooserController alloc] initWithNibName:@"BWSSubmodalityChooserController" bundle:nil];
        chooser.item = item;
        
        chooser.modality = [BWSModalityMap modalityForString:item.modality];
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigation animated:YES completion:NULL];
    }
    else {
        //show the full selection walkthrough
        BWSModalityChooserController *chooser = [[BWSModalityChooserController alloc] initWithNibName:@"BWSModalityChooserController" bundle:nil];
        chooser.item = item;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigation animated:YES completion:NULL];
    }
    
    //scroll the thing to visible if it's not, in case we come back and need to show the capture popover.
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    
}

-(void) didCompleteSensorWalkthrough:(NSNotification*)notification
{
    //This won't be attached to anything yet.
    BWSCDItem *sourceItem = [notification.userInfo objectForKey:kDictKeyTargetItem];
    
    //get the currently active record and add the item.
    BWSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [person addItemsObject:sourceItem];
    
    //If necessary, show the popover.
    if (shouldRestoreCapturePopover) {
        DDLogBWSVerbose(@"%@", @"Asking current cell to show capture popover");
        BWSPersonTableViewCell *activeCell = (BWSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        [activeCell showCapturePopoverForItem:sourceItem];
        
        shouldRestoreCapturePopover = NO;
    }
    
    //save the context.
    [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
}

-(void) didCancelSensorWalkthrough:(NSNotification*)notification
{
    BWSCDItem *sourceItem = [notification.userInfo objectForKey:kDictKeyTargetItem];
    
    //If necessary, show the popover.
    if (shouldRestoreCapturePopover) {
        BWSPersonTableViewCell *activeCell = (BWSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [activeCell showCapturePopoverForItem:sourceItem];
        
        shouldRestoreCapturePopover = NO;
    }
    
}


-(void) startItemCapture:(NSNotification *)notification
{
    BWSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];
    
    if (!item) {
        DDLogBWSVerbose(@"%@", @"Requested capture for a nonexistant item. Ignoring...");
        return;
    }
    
    DDLogBWSVerbose(@"Requested capture to start for item %@",item.description);
    
    //Get a reference to this link
    BWSDeviceLink *link = [[BWSDeviceLinkManager defaultManager] deviceForUri:item.deviceConfig.uri];
    
    if (!link) {
        DDLogBWSVerbose(@"startItemCapture couldn't find a sensor link for URI %@. Ignoring.",item.deviceConfig.uri);
        return;
    }
    
    //If the link is either not registered or not initialized,
    //run the full sequence (through downloading)
    BOOL startedOK;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                   [NSKeyedUnarchiver unarchiveObjectWithData:item.deviceConfig.parameterDictionary]];
    if (!link.registered || !link.initialized) {
        startedOK = [link beginFullSequenceWithConfigurationParams:params
                                                       withMaxSize:kMaxImageSize deviceID:[notification.userInfo objectForKey:kDictKeyDeviceID]];
        if (!startedOK) {
            DDLogBWSVerbose(@"%@", @"BWSViewController::startItemCapture couldn't start the full sequence.");
        }
        
    }
    else
    {
        startedOK = [link beginConfigCaptureDownloadSequence:link.currentSessionId
                                         configurationParams:params
                                                 withMaxSize:kMaxImageSize
                                                    deviceID:[notification.userInfo objectForKey:kDictKeyDeviceID]];
        if (!startedOK) {
            DDLogBWSVerbose(@"%@",@"BWSViewController::startItemCapture couldn't start the config-capture-download sequence.");
        }
        else {
            DDLogBWSVerbose(@"%@",@"BWSViewController::startItemCapture started the config-capture-download sequence successfully.");
        }
        
    }
    
}

-(void) stopItemCapture:(NSNotification *)notification
{
    BWSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];
    DDLogBWSVerbose(@"Requested capture to stop for item %@",item.description);
    
    //Get a reference to this link
    BWSDeviceLink *link = [[BWSDeviceLinkManager defaultManager] deviceForUri:item.deviceConfig.uri];
    
    [link cancel:link.currentSessionId deviceID:[notification.userInfo objectForKey:kDictKeyDeviceID]];
}

- (IBAction)showAdvancedOptionsPopover:(id)sender
{
    BWSSettingsViewController *settingsVC = [[BWSSettingsViewController alloc] initWithNibName:@"BWSSettingsView" bundle:nil];
    
    // Hide any other popover controller
    if (popoverController != nil) {
        if ([[self popoverController] isPopoverVisible] == YES) {
            [[self popoverController] dismissPopoverAnimated:YES];
            return;
        }
    }
    
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    popoverController = [[UIPopoverController alloc] initWithContentViewController:settingsNavigationController];
    [popoverController setPopoverBackgroundViewClass:[BWSPopoverBackgroundView class]];
    [popoverController setDelegate:settingsVC];
    [popoverController presentPopoverFromBarButtonItem:[[self navigationItem] rightBarButtonItem] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [[[self navigationItem] rightBarButtonItem] setStyle:UIBarButtonItemStyleDone];
}

#pragma mark - Button Action methods

-(IBAction)addFirstButtonPressed:(id)sender
{
    NSDate *now = [NSDate date];
    
    //Unlike the usual duplicate-style add, this time we need to start from scratch.
    BWSCDPerson *newPerson = [NSEntityDescription insertNewObjectForEntityForName:kBWSEntityPerson inManagedObjectContext:self.managedObjectContext];
    newPerson.timeStampCreated = now;
    newPerson.aliases = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    newPerson.datesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    newPerson.placesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    
    //Save the context
    [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    //scroll to the new position.
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
    [self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self tableView:self.tableView didSelectRowAtIndexPath:newPath]; //fire this manually, as the previous call doesn't do it.
    
    //Create a temporary item
    NSEntityDescription *entity = [NSEntityDescription entityForName:kBWSEntityItem inManagedObjectContext:self.managedObjectContext];
    BWSCDItem *newCaptureItem = (BWSCDItem*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    //insert this item at the beginning of the list.
    newCaptureItem.index = [NSNumber numberWithInt:0];
    newCaptureItem.submodality = [BWSModalityMap stringForCaptureType:kCaptureTypeNotSet];
    
    //fade the button out
    [UIView animateWithDuration:0.3 animations:^{
        ((UIButton*)sender).alpha = 0;
    }];
    
    //display the sensor walkthrough (by posting a notification)
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:newCaptureItem forKey:kDictKeyTargetItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark - TableView data source/delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.fetchedObjects count];
}

// Customize the appearance of table view cells.
//FIXME: This should be more flexible about different cell arrangements!
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //if there are 0 items, use 1 row. Otherwise, fit to the number of items.
    //FIXME: Figure out a way to query the cell's grid view to dynamically determine how many items
    //are in a row.
    float itemsPerRow = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 5 : 7;
    int numRows = MAX(1, ceil([person.items count] / itemsPerRow));
    
    if ([indexPath compare:selectedIndex] == NSOrderedSame) {
        return 224 + ((kItemCellSize + kItemCellSizeVerticalAddition + kItemCellSpacing) * numRows);
    }
    else return 40.0 + ((kItemCellSize + kItemCellSizeVerticalAddition + kItemCellSpacing) * numRows);
}

- (void)configureCell:(BWSPersonTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BWSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.person = person;
    [cell.itemGridView reloadData];
    [cell layoutGrid]; //adjust the frame if necessary
    
    //change editing status if necessary.
    [cell setEditing:(person == personBeingEdited)];
    
    if (cell.person != nil) {
        NSString *personName = nil;
        if (cell.person.firstName != nil && ([cell.person.firstName isEqualToString:@""] == NO))
            if (cell.person.lastName != nil && ([cell.person.lastName isEqualToString:@""] == NO))
                personName = [NSString stringWithFormat:@"%@ %@", cell.person.firstName, cell.person.lastName];
            else
                personName = cell.person.firstName;
            else
                personName = @"Unnamed Person";
        cell.accessibilityLabel = [NSString stringWithFormat:@"Record for %@", personName];
    } else
        cell.accessibilityLabel = @"Record for Inactive Person";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BWSPersonTableViewCell"; //this is also set in WSPersonTableViewCell's XIB file
    
    BWSPersonTableViewCell *cell = (BWSPersonTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"BWSPersonTableViewCell" owner:self
                                                        options:nil];
        
        cell = [nibViews objectAtIndex: 0];
        cell.delegate = self;
        
        [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell biographicalDataButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell editButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell deleteButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell addButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell duplicateRowButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell deletePersonOverlayViewCancelButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[cell deletePersonOverlayViewDeleteButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==  UITableViewCellEditingStyleDelete)
        [[aTableView cellForRowAtIndexPath:indexPath] stopLoggingBWSInterfaceEvents];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath;
    
    [aTableView reloadData];
    
    //If this is a currently deselected row, scroll to it.
    if (selectedIndex.section != previousSelectedIndex.section || selectedIndex.row != previousSelectedIndex.row) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        // reloadData resets selection (begin/endUpdates doesn't, but animates height change
        [[aTableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
    } else
        [[aTableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:NO];
    
    // reloadData causes the row to become deselected, but is necessary to adjust row height
    [aTableView selectRowAtIndexPath:selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
    previousSelectedIndex = selectedIndex;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kBWSEntityPerson inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStampCreated" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    DDLogBWSVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *aTableView = self.tableView;
    NSMutableArray *reloadPaths;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            selectedIndex = nil;
            
            [aTableView beginUpdates];
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            //reload everything after that.
            reloadPaths = [[NSMutableArray alloc] init];
            for (int i = indexPath.row+1; i < [self.fetchedResultsController.fetchedObjects count]; i++) {
                [reloadPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            }
            [aTableView reloadRowsAtIndexPaths:reloadPaths withRowAnimation:UITableViewRowAnimationFade];
            [aTableView endUpdates];
            //Show or hide the big plus button
            self.addFirstButton.alpha = [self.fetchedResultsController.fetchedObjects count] > 0 ? 0.0 : 1.0;
            break;
            
        case NSFetchedResultsChangeUpdate:
            //update data, then reload
            [(BWSPersonTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] updateData];
            [self configureCell:(BWSPersonTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        DDLogBWSVerbose(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - WSPersonTableViewCell delegate
-(void) didRequestDuplicatePerson:(BWSCDPerson*)oldPerson
{
    if(oldPerson) {
        //if we have something to duplicate, do it.
        BWSCDPerson *newPerson = (BWSCDPerson*)[oldPerson cloneInContext:self.managedObjectContext exludeEntities:nil];
        newPerson.timeStampCreated = [NSDate date];
        
        //clear out any biographical data present in the old row.
        newPerson.firstName = nil;
        newPerson.middleName = nil;
        newPerson.lastName = nil;
        newPerson.otherName = nil;
        newPerson.aliases = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
        newPerson.datesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
        newPerson.placesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
        
        newPerson.gender = nil;
        
        newPerson.hairColor = nil;
        newPerson.race = nil;
        newPerson.eyeColor = nil;
        newPerson.height = nil;
        newPerson.weight = nil;
        
        newPerson.notes = nil;
        
        for (BWSCDItem *item in newPerson.items) {
            item.timeStampCreated = [NSDate date];
            item.data = nil;
            item.thumbnail = nil;
            item.dataContentType = nil;
            item.captureMetadata = nil;
            item.annotations = nil;
            item.notes = nil;
        }
        
        //Save the context
        [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
        
        //select and scroll to the new position.
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        
        [self tableView:self.tableView didSelectRowAtIndexPath:newPath];
    }
}

-(void) didRequestDeletePerson:(BWSCDPerson*)oldPerson
{
    if (oldPerson) {
        [self.managedObjectContext deleteObject:oldPerson];
    }
}

-(void) didChangeEditingStatusForPerson:(BWSCDPerson*)person newStatus:(BOOL)onOrOff
{
    if (onOrOff) {
        //set the personBeingEdited variable.
        personBeingEdited = person;
    }
    else {
        //set the person being edited to nil.
        personBeingEdited = nil;
    }
}

#pragma mark - UIPopoverController delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    BWSPersonTableViewCell *activeCell = (BWSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [activeCell selectItem:nil]; //clear selection
    [self.view logPopoverControllerDismissed:aPopoverController];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillAppear:(NSNotification *)notification
{
    // Shrink the tableview when showing keyboard in landscape mode
    if (UIDeviceOrientationIsLandscape([self interfaceOrientation])) {
        CGRect rect = self.tableView.frame;
        rect.size.height -= 190;
        [UIView animateWithDuration:0.3 animations:^(){ self.tableView.frame = rect; }];
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    keyboardShown = YES;
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    NSLog(@"interfaceOrientation Orientation is %d", [self interfaceOrientation]);
    if (UIDeviceOrientationIsLandscape([self interfaceOrientation])) {
        NSLog(@"Landscape keyboardDisappear");
        CGRect rect = self.tableView.frame;
        rect.size.height += 190;
        [UIView animateWithDuration:0.3 animations:^(){ self.tableView.frame = rect; }];
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    keyboardShown = NO;
}

@end
