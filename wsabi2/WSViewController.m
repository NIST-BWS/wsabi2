//
//  WSViewController.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/10/12.
 
//

#import "WSViewController.h"

#import "WSAppDelegate.h"
#import "NSManagedObject+DeepCopy.h"

@implementation WSViewController
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
    self.popoverController.popoverBackgroundViewClass = [WSPopoverBackgroundView class];
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Record if the flip side of the CaptureController is presently shown
    WSPersonTableViewCell *cell = (WSPersonTableViewCell *)[[self tableView] cellForRowAtIndexPath:[[self tableView] indexPathForSelectedRow]];
    wasAnnotating = ((cell != nil) && ([cell selectedIndex] != -1) && ([[cell captureController] isAnnotating] == YES));
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // Redisplay capture controller if it was visible
    WSPersonTableViewCell *cell = (WSPersonTableViewCell *)[[self tableView] cellForRowAtIndexPath:[[self tableView] indexPathForSelectedRow]];
    if ((cell != nil) && ([cell selectedIndex] != -1)) {
        [cell showCapturePopoverAtIndex:[cell selectedIndex]];
        if (wasAnnotating)
            [[cell captureController] showFlipSideAnimated:NO];
    }
}

#pragma mark - Notification action methods
-(void) presentSensorWalkthrough:(NSNotification*)notification
{
    //start by deselecting everything in the current row.
    WSPersonTableViewCell *row = (WSPersonTableViewCell*) [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [row selectItem:nil];
    
    WSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];

    //figure out whether we should restore the capture popover later.
    //NOTE: do so unless we came from the add-new-item button.
    shouldRestoreCapturePopover = (item.managedObjectContext != nil);

    // Start from device
    if ([[notification.userInfo objectForKey:kDictKeyStartFromDevice] boolValue]) {
        //only show the walkthrough from device selection onwards.
        WSDeviceChooserController *chooser = [[WSDeviceChooserController alloc] initWithNibName:@"WSDeviceChooserController" bundle:nil];
        chooser.item = item;

        //FIXME: Set the modality/submodality either here or in the chooser automatically
        chooser.modality = [WSModalityMap modalityForString:item.modality];
        chooser.submodality = [WSModalityMap captureTypeForString:item.submodality];
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navigation animated:YES];    
        
        //once they're presented, add logging capabilities.
        [navigation.navigationBar startAutomaticGestureLogging:YES];
        [chooser.view startAutomaticGestureLogging:YES];
    // Start from submodality
    } else if ([[notification.userInfo objectForKey:kDictKeyStartFromSubmodality] boolValue]) {
        WSSubmodalityChooserController *chooser = [[WSSubmodalityChooserController alloc] initWithNibName:@"WSSubmodalityChooserController" bundle:nil];
        chooser.item = item;
        
        chooser.modality = [WSModalityMap modalityForString:item.modality];
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navigation animated:YES];
        
        //once they're presented, add logging capabilities.
        [navigation.navigationBar startAutomaticGestureLogging:YES];
        [chooser.view startAutomaticGestureLogging:YES];
    }
    else {
        //show the full selection walkthrough
        WSModalityChooserController *chooser = [[WSModalityChooserController alloc] initWithNibName:@"WSModalityChooserController" bundle:nil];
        chooser.item = item;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navigation animated:YES];    

        //once they're presented, add logging capabilities.
        [navigation.navigationBar startAutomaticGestureLogging:YES];
        [chooser.view startAutomaticGestureLogging:YES];

    }
    
    //scroll the thing to visible if it's not, in case we come back and need to show the capture popover.
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];

}

-(void) didCompleteSensorWalkthrough:(NSNotification*)notification
{
    //This won't be attached to anything yet.
    WSCDItem *sourceItem = [notification.userInfo objectForKey:kDictKeyTargetItem];

    //get the currently active record and add the item.
    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [person addItemsObject:sourceItem];

    //FIXME: Unfortunately, launching the capture popover from here results in a popover that WILL NOT
    //be dismissed when a grid cell is tapped. I have no idea why this is. To avoid it during testing,
    //we're removing this call. Uncomment and fix whenever possible.
        
    //If necessary, show the popover.
    if (shouldRestoreCapturePopover) {
        NSLog(@"Asking current cell to show capture popover");
        WSPersonTableViewCell *activeCell = (WSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        [activeCell showCapturePopoverForItem:sourceItem];
        
        shouldRestoreCapturePopover = NO;
    }
    
    //save the context.
    [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
 
    
    
}

-(void) didCancelSensorWalkthrough:(NSNotification*)notification
{
    WSCDItem *sourceItem = [notification.userInfo objectForKey:kDictKeyTargetItem];

    //If necessary, show the popover.
    if (shouldRestoreCapturePopover) {
        WSPersonTableViewCell *activeCell = (WSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [activeCell showCapturePopoverForItem:sourceItem];

        shouldRestoreCapturePopover = NO;
    }

}


-(void) startItemCapture:(NSNotification *)notification
{
    WSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];
    
    if (!item) {
        NSLog(@"Requested capture for a nonexistant item. Ignoring...");
        return;
    }
    
    NSLog(@"Requested capture to start for item %@",item.description);
    
    //Get a reference to this link
    NBCLDeviceLink *link = [[NBCLDeviceLinkManager defaultManager] deviceForUri:item.deviceConfig.uri];
    
    if (!link) {
        NSLog(@"startItemCapture couldn't find a sensor link for URI %@. Ignoring.",item.deviceConfig.uri);
        return;
    }

    //If the link is either not registered or not initialized,
    //run the full sequence (through downloading)
    BOOL startedOK;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                   [NSKeyedUnarchiver unarchiveObjectWithData:item.deviceConfig.parameterDictionary]];
    if (!link.registered || !link.initialized) {
        startedOK = [link beginFullSequenceWithConfigurationParams:params
                                           withMaxSize:kMaxImageSize sourceObjectID:[notification.userInfo objectForKey:kDictKeySourceID]];
        if (!startedOK) {
            NSLog(@"WSViewController::startItemCapture couldn't start the full sequence.");
        }

    }
    else
    {
        startedOK = [link beginConfigCaptureDownloadSequence:link.currentSessionId
                             configurationParams:params
                                     withMaxSize:kMaxImageSize
                                   sourceObjectID:[notification.userInfo objectForKey:kDictKeySourceID]];
        if (!startedOK) {
            NSLog(@"WSViewController::startItemCapture couldn't start the config-capture-download sequence.");
        }
        else {
            NSLog(@"WSViewController::startItemCapture started the config-capture-download sequence successfully.");
        }

    }
    
}

-(void) stopItemCapture:(NSNotification *)notification
{
    WSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];
    NSLog(@"Requested capture to stop for item %@",item.description);
    
    //Get a reference to this link
    NBCLDeviceLink *link = [[NBCLDeviceLinkManager defaultManager] deviceForUri:item.deviceConfig.uri];
    
    [link beginCancel:link.currentSessionId sourceObjectID:[notification.userInfo objectForKey:kDictKeySourceID]];
}

#pragma mark - Button Action methods

-(IBAction)addFirstButtonPressed:(id)sender
{
    NSDate *now = [NSDate date];
    
    //Unlike the usual duplicate-style add, this time we need to start from scratch.
    WSCDPerson *newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"WSCDPerson" inManagedObjectContext:self.managedObjectContext];
    newPerson.timeStampCreated = now;
    newPerson.aliases = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    newPerson.datesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    newPerson.placesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
        
    //Save the context
    [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    //scroll to the new position.
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
    [self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self tableView:self.tableView didSelectRowAtIndexPath:newPath]; //fire this manually, as the previous call doesn't do it.
    
    //Create a temporary item
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WSCDItem" inManagedObjectContext:self.managedObjectContext];
    WSCDItem *newCaptureItem = (WSCDItem*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    //insert this item at the beginning of the list.
    newCaptureItem.index = [NSNumber numberWithInt:0]; 
    newCaptureItem.submodality = [WSModalityMap stringForCaptureType:kCaptureTypeNotSet];
    
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
    //NSLog(@"Index path for selected row is (%d,%d)",selectedIndex.section, selectedIndex.row);
    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //if there are 0 items, use 1 row. Otherwise, fit to the number of items.
    //FIXME: Figure out a way to query the cell's grid view to dynamically determine how many items 
    //are in a row.
    float itemsPerRow = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 5 : 7;
    int numRows = MAX(1, ceil([person.items count] / itemsPerRow)); 
    
    //NSLog(@"Row %d should have %d rows",indexPath.row, numRows);
    
    if ([indexPath compare:selectedIndex] == NSOrderedSame) {
        return 224 + ((kItemCellSize + kItemCellSizeVerticalAddition + kItemCellSpacing) * numRows);
    }
    else return 40.0 + ((kItemCellSize + kItemCellSizeVerticalAddition + kItemCellSpacing) * numRows);
}

- (void)configureCell:(WSPersonTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.person = person;
    [cell.itemGridView reloadData];
    [cell layoutGrid]; //adjust the frame if necessary
    
    //change editing status if necessary.
    [cell setEditing:(person == personBeingEdited)];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WSPersonTableViewCell"; //this is also set in WSPersonTableViewCell's XIB file
    
    WSPersonTableViewCell *cell = (WSPersonTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"WSPersonTableViewCell" owner:self
                                                        options:nil];
        
        cell = [nibViews objectAtIndex: 0];
        cell.delegate = self;
        //turn on gesture logging for new cells
        [cell startAutomaticGestureLogging:YES];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the managed object for the given index path
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        // Save the context.
//        NSError *error = nil;
//        if (![context save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//
//
//    }   
//}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath;
    
    [aTableView reloadData];
    // reloadData causes the row to become deselected, but is necessary to adjust row height
    [aTableView selectRowAtIndexPath:selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];

    //If this is a currently deselected row, scroll to it.
    if (selectedIndex.section != previousSelectedIndex.section || selectedIndex.row != previousSelectedIndex.row) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        // reloadData resets selection (begin/endUpdates doesn't, but animates height change
        [[aTableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:YES];
    } else
        [[aTableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:NO];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WSCDPerson" inManagedObjectContext:self.managedObjectContext];
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
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
            [(WSPersonTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] updateData];
            [self configureCell:(WSPersonTableViewCell*)[aTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - WSPersonTableViewCell delegate
-(void) didRequestDuplicatePerson:(WSCDPerson*)oldPerson
{
    if(oldPerson) {
        //if we have something to duplicate, do it.
        WSCDPerson *newPerson = (WSCDPerson*)[oldPerson cloneInContext:self.managedObjectContext exludeEntities:nil];
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
        
        for (WSCDItem *item in newPerson.items) {
            item.timeStampCreated = [NSDate date];
            item.data = nil;
            item.thumbnail = nil;
            item.dataContentType = nil;
            item.captureMetadata = nil;
            item.annotations = nil;
            item.notes = nil;
        }
        
        //Save the context
        [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];

        //select and scroll to the new position.
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];

        [self tableView:self.tableView didSelectRowAtIndexPath:newPath];
    }
}

-(void) didRequestDeletePerson:(WSCDPerson*)oldPerson
{
    if (oldPerson) {
        [self.managedObjectContext deleteObject:oldPerson];
    }
}

-(void) didChangeEditingStatusForPerson:(WSCDPerson*)person newStatus:(BOOL)onOrOff
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
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    WSPersonTableViewCell *activeCell = (WSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [activeCell selectItem:nil]; //clear selection
    [self.view logPopoverHidden];
}

#pragma mark - UIScrollView delegate (for logging)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tableView logScrollStarted];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView logScrollChanged];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.tableView logScrollEnded];
}

@end
