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
#import "WSModalityMap.h"
#import "constants.h"

#import "WSSettingsShowSensorsViewController.h"

@interface WSSettingsShowSensorsViewController ()

/// List of the sensors retrieved from the backing store
@property (nonatomic, strong) NSDictionary *sensors;

/// Obtain a dictionary of all sensors, where the key is the modality number
- (NSDictionary *)retrieveAllSensors;
/// Obtain an array of all sensors, given a modality number
- (NSArray *)retrieveSensorsForModality:(WSSensorModalityType)modality;

@end

@implementation WSSettingsShowSensorsViewController

@synthesize sensors = _sensors;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationItem] setTitle:kWSSettingsShowSensorsLabel];
    [self setSensors:[self retrieveAllSensors]];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@: %@ %@ (%@)", [device uri], device.item.person.firstName, device.item.person.lastName, device.item.submodality]];
    
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
    return ([WSModalityMap stringForModality:section]);
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(modalities like %@)", [WSModalityMap stringForModality:modality]];
    
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
