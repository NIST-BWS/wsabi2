//
//  WSDeviceChooserController.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSDeviceChooserController.h"

#import "WSAppDelegate.h"

@implementation WSDeviceChooserController
@synthesize submodality;
@synthesize modality;
@synthesize item;
@synthesize autodiscoveryEnabled;
@synthesize currentButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    self.title = [WSModalityMap stringForCaptureType:self.submodality];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //If this is the root view controller, we're launching the config workflow partway through.
    //We need a way to leave this controller in that case.
    if (self == [self.navigationController.viewControllers objectAtIndex:0]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    

    //Fetch a list of recent sensors from Core Data
    
    //Since we might be working on a temporary object, don't ask it for a managed object context.
    //Instead, get the primary context from the app delegate.
    NSManagedObjectContext *moc = [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"WSCDDeviceDefinition" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    //FIXME: This is currently disabled, because we'll need to get data from the sensors before
    //being able to filter
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(modalities like %@)",
                              [WSModalityMap stringForModality:self.modality], 
                              [WSModalityMap stringForCaptureType:self.submodality]];
    [request setPredicate:predicate];
    
    //get a sorted list of the recent sensors
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStampLastEdit" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *rawRecentSensors = [moc executeFetchRequest:request error:&error];
    if (rawRecentSensors == nil)
    {
        NSLog(@"Couldn't get a list of recent sensors, error was: %@",[error description]);
    }
    
    //NOTE: Not speedy. O(n^2)ish.
    recentSensors = [[NSMutableArray alloc] init];
    for (WSCDDeviceDefinition *dev in rawRecentSensors) {
        BOOL unique = YES;
        //if this isn't in the pruned recent sensors list already, add it.
        for (WSCDDeviceDefinition *existingDev in recentSensors) {
            if ([existingDev.uri isEqualToString:dev.uri] && [existingDev.name isEqualToString:dev.name]) {
                //this isn't unique, so don't add it.
                unique = NO;
            }
        }
        if (unique) {
            [recentSensors addObject:dev];
        }
    }
    
    NSLog(@"Found %d unique recent sensors matching these criteria",[recentSensors count]);
    
    //Set up the current sensor button
    if (self.item.managedObjectContext && self.item.deviceConfig
        && (self.modality == [WSModalityMap modalityForString:self.item.modality])
        && (self.submodality == [WSModalityMap captureTypeForString:self.item.submodality])) {
        self.currentButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Use current settings"]
                                                              style:UIBarButtonItemStyleDone
                                                             target:self action:@selector(currentButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.currentButton;
    }
    

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

#pragma mark - Button action methods
-(IBAction) cancelButtonPressed:(id)sender
{
    //post a notification to hide the device chooser and return to the previous state
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:item forKey:kDictKeyTargetItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];

    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction) currentButtonPressed:(id)sender
{
    //Push a new controller to configure the device.
    WSDeviceSetupController *subChooser = [[WSDeviceSetupController alloc] initWithNibName:@"WSDeviceSetupController" bundle:nil];
    
    subChooser.item = self.item; //pass the data object
    subChooser.modality = self.modality;
    subChooser.submodality = self.submodality;
 
    //NOTE: We can't use cloneInContext here, because we have no context to clone into (or at least we might not). Copy manually.
    //Create a new temporary item and fill it.
    NSManagedObjectContext *moc = [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WSCDDeviceDefinition" inManagedObjectContext:moc];
    WSCDDeviceDefinition *newDef = (WSCDDeviceDefinition*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    newDef.inactivityTimeout = self.item.deviceConfig.inactivityTimeout;
    newDef.modalities = self.item.deviceConfig.modalities;
    newDef.mostRecentSessionId = self.item.deviceConfig.mostRecentSessionId;
    newDef.name = self.item.deviceConfig.name;
    newDef.parameterDictionary = self.item.deviceConfig.parameterDictionary;
    newDef.submodalities = self.item.deviceConfig.submodalities;
    newDef.uri = self.item.deviceConfig.uri;
    
    newDef.timeStampLastEdit = [NSDate date];
    subChooser.deviceDefinition = newDef;

      
    [self.navigationController pushViewController:subChooser animated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.autodiscoveryEnabled) {
        if (recentSensors && [recentSensors count] > 0) {
            return 3;
        }
        else return 2;
    }
    else {
        if (recentSensors && [recentSensors count] > 0) {
            return 2;
        }
        else return 1;

    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.autodiscoveryEnabled) {
        //Everything
        if (recentSensors && [recentSensors count] > 0) {
            switch (section) {
                case 0:
                    //return the number of recent sensors stored for this modality, capped at our maximum
                    return MIN([recentSensors count], NUM_RECENT_SENSORS);
                    break;
                case 1:
                    //return the number of autodiscovered sensors found for this modality.
                    break;
                case 2:
                    return 1; //only one row for the add button
                    break;
                default:
                    break;
            }
        }
        //No recents
        else {
            switch (section) {
                case 0:
                    //return the number of autodiscovered sensors found for this modality.
                    break;
                case 1:
                    return 1; //only one row for the add button
                    break;
                default:
                    break;
            }

        }
    }
    else {
        //No autodiscovered
        if (recentSensors && [recentSensors count] > 0) {
            switch (section) {
                case 0:
                    //return the number of recent sensors stored for this modality, capped at our maximum
                    return MIN([recentSensors count], NUM_RECENT_SENSORS);
                    break;
                case 1:
                    return 1; //only one row for the add button
                    break;
                default:
                    break;
            }
        }
        //Just the "add new" section
        else {
            switch (section) {
                case 0:
                    return 1; //only one row for the add button
                    break;
                default:
                    break;
            }

        }
        
    }
 
    // Return the number of rows in the section.
    return 0;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.autodiscoveryEnabled) {
        //Everything
        if (recentSensors && [recentSensors count] > 0) {
            switch (section) {
                case 0:
                    return @"Recent sensors";
                    break;
                case 1:
                    return @"Autodiscovered sensors";
                    break;
                 default:
                    break;
            }
        }
        //No recents
        else {
            switch (section) {
                case 0:
                    return @"Autodiscovered sensors";
                    break;
                 default:
                    break;
            }
            
        }
    }
    else {
        //No autodiscovered
        if (recentSensors && [recentSensors count] > 0) {
            switch (section) {
                case 0:
                    return @"Recent sensors";
                    break;
                default:
                    break;
            }
        }
    }
    
    // Return the number of rows in the section.
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //enable touch logging for new cells
        [cell startAutomaticGestureLogging:YES];
    }
    
    
    NSString *titleString = nil;
    NSString *subtitleString = nil;
    // Configure the cell...
    if (self.autodiscoveryEnabled) {
        //Everything
        if (recentSensors && [recentSensors count] > 0) {
            switch (indexPath.section) {
                case 0:
                    titleString = [(WSCDDeviceDefinition*)[recentSensors objectAtIndex:indexPath.row] name];
                    subtitleString = [(WSCDDeviceDefinition*)[recentSensors objectAtIndex:indexPath.row] uri];
                    break;
                case 1:
                    //return the number of autodiscovered sensors found for this modality.
                    break;
                case 2:
                    titleString = @"Add a new sensor";
                    break;
                default:
                    break;
            }
        }
        //No recents
        else {
            switch (indexPath.section) {
                case 0:
                    //return the number of autodiscovered sensors found for this modality.
                    break;
                case 1:
                    titleString = @"Add a new sensor";
                    break;
                default:
                    break;
            }
            
        }
    }
    else {
        //No autodiscovered
        if (recentSensors && [recentSensors count] > 0) {
            switch (indexPath.section) {
                case 0:
                    titleString = [(WSCDDeviceDefinition*)[recentSensors objectAtIndex:indexPath.row] name];
                    subtitleString = [(WSCDDeviceDefinition*)[recentSensors objectAtIndex:indexPath.row] uri];
                    break;
                case 1:
                    titleString = @"Add a new sensor";
                    break;
                default:
                    break;
            }
        }
        //Just the "add new" section
        else {
            switch (indexPath.section) {
                case 0:
                    titleString = @"Add a new sensor";
                    break;
                default:
                    break;
            }
            
        }
        
    }
    
    cell.textLabel.text = titleString;
    cell.detailTextLabel.text = subtitleString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
    //Push a new controller to configure the device.
    WSDeviceSetupController *subChooser = [[WSDeviceSetupController alloc] initWithNibName:@"WSDeviceSetupController" bundle:nil];
    
    subChooser.item = self.item; //pass the data object
    subChooser.modality = self.modality;
    subChooser.submodality = self.submodality;
        
    //Configure the device definition
    //FIXME: Either choose an existing def and copy it, or start with a new def here.

    WSCDDeviceDefinition *def = nil;
    BOOL createNewDef = NO;
    if (self.autodiscoveryEnabled) {
        //Everything
        if (recentSensors && [recentSensors count] > 0) {
            switch (indexPath.section) {
                case 0:
                    //duplicate this sensor
                    def = [recentSensors objectAtIndex:indexPath.row];
                    break;
                case 1:
                    //return the number of autodiscovered sensors found for this modality.
                    break;
                case 2:
                    createNewDef = YES;
                    break;
                default:
                    break;
            }
        }
        //No recents
        else {
            switch (indexPath.section) {
                case 0:
                    //return the number of autodiscovered sensors found for this modality.
                    break;
                case 1:
                    createNewDef = YES;
                    break;
                default:
                    break;
            }
            
        }
    }
    else {
        //No autodiscovered
        if (recentSensors && [recentSensors count] > 0) {
            switch (indexPath.section) {
                case 0:
                    //duplicate this sensor
                    def = [recentSensors objectAtIndex:indexPath.row];
                    break;
                case 1:
                    createNewDef = YES;
                    break;
                default:
                    break;
            }
        }
        //Just the "add new" section
        else {
            switch (indexPath.section) {
                case 0:
                    createNewDef = YES;
                    break;
                default:
                    break;
            }
            
        }
        
    }
    
    //NOTE: We're not actually connecting the device definition with the item yet;
    //that happens when the user clicks the DONE button in the device setup controller.
    
    //If we need to create a new device def, do so.
    if (!def && createNewDef) {
        //Create a temporary item
        NSManagedObjectContext *moc = [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"WSCDDeviceDefinition" inManagedObjectContext:moc];
        WSCDDeviceDefinition *newDef = (WSCDDeviceDefinition*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        newDef.timeStampLastEdit = [NSDate date];
        subChooser.deviceDefinition = newDef; 
    }
    else if (def) {        
        //NOTE: We can't use cloneInContext here, because we have no context to clone into (or at least we might not). Copy manually.
        //Create a new temporary item and fill it.
        NSManagedObjectContext *moc = [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"WSCDDeviceDefinition" inManagedObjectContext:moc];
        WSCDDeviceDefinition *newDef = (WSCDDeviceDefinition*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        newDef.inactivityTimeout = def.inactivityTimeout;
        newDef.modalities = def.modalities;
        newDef.mostRecentSessionId = def.mostRecentSessionId;
        newDef.name = def.name;
        newDef.parameterDictionary = def.parameterDictionary;
        newDef.submodalities = def.submodalities;
        newDef.uri = def.uri;
        
        newDef.timeStampLastEdit = [NSDate date];
        subChooser.deviceDefinition = newDef;
    }

    
    [self.navigationController pushViewController:subChooser animated:YES];
}

@end
