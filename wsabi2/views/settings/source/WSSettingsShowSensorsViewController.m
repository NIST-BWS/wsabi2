//
//  WSSettingsShowSensorsViewController.m
//  wsabi2
//
//  Created by Greg Fiumara on 10/12/12.
//
//

#import "WSAppDelegate.h"
#import "WSCDItem.h"
#import "WSCDPerson.h"
#import "WSCDDeviceDefinition.h"
#import "BWSModalityMap.h"
#import "WSSettingsAddSensorViewController.h"
#import "constants.h"

#import "WSSettingsShowSensorsViewController.h"

@interface WSSettingsShowSensorsViewController ()

/// List of the sensors retrieved from the backing store
@property (nonatomic, strong) NSDictionary *sensors;

/// Obtain a dictionary of all sensors, where the key is the modality number
- (NSDictionary *)retrieveAllSensors;
/// Obtain an array of all sensors, given a modality number
- (NSArray *)retrieveSensorsForModality:(WSSensorModalityType)modality;
/// Add a new sensor
- (IBAction)addSensor:(id)sender;

@end

@implementation WSSettingsShowSensorsViewController

@synthesize sensors = _sensors;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addSensorButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSensor:)];
    [[self navigationItem] setRightBarButtonItem:addSensorButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setSensors:[self retrieveAllSensors]];
    [[self tableView] reloadData];
    
    [super viewWillAppear:animated];
}

#pragma mark - Events

- (IBAction)addSensor:(id)sender
{
    WSSettingsAddSensorViewController *addSensorVC = [[WSSettingsAddSensorViewController alloc] initWithNibName:@"WSSettingsAddSensorView" bundle:nil];
    [[self navigationController] pushViewController:addSensorVC animated:YES];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TableView Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"SettingsDeviceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    WSCDDeviceDefinition *device = [[[self sensors] objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.section]] objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[device name]];
    if (device.item == NULL)
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@: %@", [device uri], NSLocalizedString(@"Unassociated", @"Not associated with any item")]];
    else
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@: %@ %@ (%@)",
                                         [device uri],
                                         device.item.person.firstName != nil ? device.item.person.firstName : @"<NFN>",
                                         device.item.person.lastName != nil ? device.item.person.lastName : @"<NLN>",
                                         device.item.submodality]];
    
    return (cell);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([[[self sensors] objectForKey:[NSNumber numberWithInteger:section]] count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([[self sensors] count]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ([BWSModalityMap stringForModality:section]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSCDDeviceDefinition *device = [[[self sensors] objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.section]] objectAtIndex:indexPath.row];
    return ([device item] == nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        // Delete device
        NSManagedObjectContext *moc = [(WSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        WSCDDeviceDefinition *device = [[[self sensors] objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.section]] objectAtIndex:indexPath.row];
        [moc deleteObject:device];
        [(WSAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
        
        // Reload table
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setSensors:[self retrieveAllSensors]];
        
        [tableView endUpdates];
    }
}

#pragma mark - Popover Settings

- (CGSize)contentSizeForViewInPopover
{
    [[self view] sizeToFit];
    
    // Ensure we don't make the popover taller than the screen
    return (CGSizeMake([[self view] frame].size.width, MIN([[self view] frame].size.height, [[UIScreen mainScreen] bounds].size.height)));
}

#pragma mark - CoreData Manipulation

- (NSDictionary *)retrieveAllSensors
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:kModality_COUNT];
    
    for (NSUInteger modality = 0; modality < kModality_COUNT; modality++)
        [dictionary setObject:[self retrieveSensorsForModality:modality] forKey:[NSNumber numberWithUnsignedInteger:modality]];
    
    return (dictionary);
}

- (NSArray *)retrieveSensorsForModality:(WSSensorModalityType)modality
{
    if (modality > kModality_COUNT)
        return ([[NSArray alloc] init]);
    
    NSManagedObjectContext *moc = [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kWSEntityDeviceDefinition inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(modalities like %@)", [BWSModalityMap stringForModality:modality]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    //get a sorted list of the recent sensors
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *retrievedSensors = [moc executeFetchRequest:request error:&error];
    if (error != nil || retrievedSensors == nil)
        NSLog(@"%@", [error description]);
    
    return (retrievedSensors);
}

@end
