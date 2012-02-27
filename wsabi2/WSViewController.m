//
//  WSViewController.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSViewController.h"

#import "WSAppDelegate.h"
#import "NSManagedObject+DeepCopy.h"

@implementation WSViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize tableView;
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
    
    self.fetchedResultsController.delegate = self;

    self.addFirstButton.alpha = [self.fetchedResultsController.fetchedObjects count] > 0 ? 0.0 : 1.0;
    
    //Add notification listeners for global actions we want to catch
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentSensorWalkthrough:)
                                                 name:kShowWalkthroughNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didHideSensorWalkthrough:)
                                                 name:kHideWalkthroughNotification
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

#pragma mark - Button Action methods
-(void) presentSensorWalkthrough:(NSNotification*)notification
{
    BOOL shouldStartFromDevice = [[notification.userInfo objectForKey:kDictKeyStartFromDevice] boolValue];
    if (shouldStartFromDevice) {
        //only show the walkthrough from device selection onwards.
        WSDeviceChooserController *chooser = [[WSDeviceChooserController alloc] initWithNibName:@"WSDeviceChooserController" bundle:nil];
        WSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];
        chooser.item = item;

        //FIXME: Set the modality/submodality either here or in the chooser automatically
        chooser.modality = [WSModalityMap modalityForString:item.modality];
        chooser.submodality = [WSModalityMap captureTypeForString:item.submodality];
        
        chooser.walkthroughDelegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navigation animated:YES];    
    }
    else {
        //show the full selection walkthrough
        WSModalityChooserController *chooser = [[WSModalityChooserController alloc] initWithNibName:@"WSModalityChooserController" bundle:nil];
        chooser.item = [notification.userInfo objectForKey:kDictKeyTargetItem];
        chooser.walkthroughDelegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:chooser];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navigation animated:YES];    
    }
}

-(void) didHideSensorWalkthrough:(NSNotification*)notification
{
    //launch the popover for the correct item.
    WSPersonTableViewCell *activeCell = (WSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [activeCell showCapturePopoverForItem:[notification.userInfo objectForKey:kDictKeyTargetItem]];
}


-(IBAction)addFirstButtonPressed:(id)sender
{
    NSDate *now = [NSDate date];
    
    //Unlike the usual duplicate-style add, this time we need to start from scratch.
    WSCDPerson *newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"WSCDPerson" inManagedObjectContext:self.managedObjectContext];
    newPerson.timeStampCreated = now;
    newPerson.aliases = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    newPerson.datesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    newPerson.placesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    
    //create a new capture item
    WSCDItem *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"WSCDItem" inManagedObjectContext:self.managedObjectContext];
    newItem.index = [NSNumber numberWithInt:0]; //this is the first item in the record
    newItem.timeStampCreated = now;
    newItem.submodality = [WSModalityMap stringForCaptureType:kCaptureTypeNotSet];
    
    //add a device config to that item.
    WSCDDeviceDefinition *deviceDef = [NSEntityDescription insertNewObjectForEntityForName:@"WSCDDeviceDefinition" inManagedObjectContext:self.managedObjectContext];
    deviceDef.timeStampLastEdit = now;
    newItem.deviceConfig = deviceDef;
    
    //add that item to the person's record.
    [newPerson addItemsObject:newItem];
    
    //Save the context
    [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    //scroll to the new position.
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
    [self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self tableView:self.tableView didSelectRowAtIndexPath:newPath]; //fire this manually, as the previous call doesn't do it.
    
    //fade the button out
    [UIView animateWithDuration:0.3 animations:^{
        ((UIButton*)sender).alpha = 0;
    }];
    
    //display the sensor walkthrough (by posting a notification)
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:newItem forKey:kDictKeyTargetItem];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Index path for selected row is (%d,%d)",selectedIndex.section, selectedIndex.row);
    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //if there are 0 items, use 1 row. Otherwise, fit to the number of items.
    int numRows = MAX(1, ceil([person.items count] / 5.0)); 
    
    //NSLog(@"Row %d should have %d rows",indexPath.row, numRows);
    
    if ([indexPath compare:selectedIndex] == NSOrderedSame) {
        return 264 + (124.0 * numRows);
    }
    else return 40.0 + (124.0 * numRows);
}

- (void)configureCell:(WSPersonTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = [person.timeStampCreated description];
    //cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.person = person;
    [cell.itemGridView reloadData];
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
    
    [aTableView beginUpdates];
    [aTableView endUpdates];
       
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
            
        case NSFetchedResultsChangeDelete:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            //Show or hide the big plus button
            self.addFirstButton.alpha = [self.fetchedResultsController.fetchedObjects count] > 0 ? 0.0 : 1.0;
            break;
            
        case NSFetchedResultsChangeUpdate:
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
        
        //Save the context
        [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
        
        //select and scroll to the new position.
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:newPath]; //fire this manually, as the previous call doesn't do it.
        [self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

    }
}

-(void) didRequestDeletePerson:(WSCDPerson*)oldPerson
{
    if (oldPerson) {
        [self.managedObjectContext deleteObject:oldPerson];
    }
}

#pragma mark - Device Config walkthrough delegate
-(void) didCancelDeviceConfigWalkthrough:(WSCDItem*)sourceItem
{
    WSPersonTableViewCell *activeCell = (WSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [activeCell showCapturePopoverForItem:sourceItem];
}

-(void) didCompleteDeviceConfigWalkthrough:(WSCDItem*)sourceItem
{
    WSPersonTableViewCell *activeCell = (WSPersonTableViewCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [activeCell showCapturePopoverForItem:sourceItem];
}

@end
