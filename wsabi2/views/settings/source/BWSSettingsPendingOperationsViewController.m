// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSAppDelegate.h"
#import "BWSConstants.h"
#import "BWSDDLog.h"
#import "BWSCDDeviceDefinition.h"
#import "BWSCDItem.h"
#import "BWSCDPerson.h"
#import "BWSDeviceLink.h"
#import "BWSDeviceLinkManager.h"
#import "UITableView+BWSUtilities.h"
#import "WSBDAFHTTPClient.h"

#import "BWSSettingsPendingOperationsViewController.h"

@interface BWSSettingsPendingOperationsViewController ()

@property (nonatomic, strong) NSArray *sensors;
@property (nonatomic, strong) NSMutableArray *sensorsWithPendingOperations;

@end

@implementation BWSSettingsPendingOperationsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getAllSensors];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

    [self getAllPendingOperations];
    [self.tableView reloadData];
}

#pragma mark - UITableViewCell Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * const kBWSSettingsPendingOperationsViewControllerCell = @"BWSSettingsPendingOperationsViewControllerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBWSSettingsPendingOperationsViewControllerCell];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kBWSSettingsPendingOperationsViewControllerCell];

	[self configureCell:cell forIndexPath:indexPath];

	return (cell);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ([self.sensorsWithPendingOperations count]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;
    //
    // Delete
    //
    BWSCDDeviceDefinition *sensor = self.sensorsWithPendingOperations[indexPath.row];
    BWSDeviceLink *deviceLink = [[BWSDeviceLinkManager defaultManager] deviceForUri:[sensor uri]];

    // Possible that operation finished in the interim
    if ([deviceLink operationInProgress] != -1)
        [deviceLink cancel:deviceLink.currentSessionId deviceID:[sensor.objectID URIRepresentation]];

    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (YES);
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    BWSCDDeviceDefinition *sensor = self.sensorsWithPendingOperations[indexPath.row];
    BWSDeviceLink *deviceLink = [[BWSDeviceLinkManager defaultManager] deviceForUri:[sensor uri]];

    cell.textLabel.text = [BWSDeviceLink stringForSensorOperationType:[deviceLink operationInProgress]];

    NSMutableString *detailString = [[NSMutableString alloc] init];
    if ((sensor.name != nil) && (![sensor.name isEqualToString:@""]))
        [detailString appendFormat:@"%@ - ", sensor.name];
    [detailString appendFormat:@"%@ ", (sensor.item.person.firstName != nil && (![sensor.item.person.firstName isEqualToString:@""]) ? sensor.item.person.firstName : @"<NFN>")];
    [detailString appendFormat:@"%@ ", (sensor.item.person.lastName != nil && (![sensor.item.person.lastName isEqualToString:@""]) ? sensor.item.person.lastName : @"<NLN>")];
    [detailString appendFormat:@"(%@)", sensor.item.submodality];
    cell.detailTextLabel.text = detailString;
}

#pragma mark - UITableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (NSLocalizedString(@"Cancel", nil));
}

#pragma mark - Model

- (void)getAllSensors
{
	NSManagedObjectContext *moc = [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kBWSEntityDeviceDefinition];
	[request setPredicate:[NSPredicate predicateWithValue:YES]];

	NSError *error = nil;
	self.sensors = [moc executeFetchRequest:request error:&error];
	if (error != nil) {
		DDLogError(@"%@", error.localizedDescription);
		self.sensors = @[];
	}
}

- (void)getAllPendingOperations
{
    if (self.sensors == nil)
        [self getAllSensors];

    if (self.sensorsWithPendingOperations == nil)
        self.sensorsWithPendingOperations = [[NSMutableArray alloc] init];
    else
        [self.sensorsWithPendingOperations removeAllObjects];

	for (BWSCDDeviceDefinition *sensor in self.sensors) {
        if ([[BWSDeviceLinkManager defaultManager] isDeviceActiveWithUri:[sensor uri]]) {
            BWSDeviceLink *deviceLink = [[BWSDeviceLinkManager defaultManager] deviceForUri:[sensor uri]];
            // TODO: There should be an "idle" progress instead of using a bad value
            if ([deviceLink operationInProgress] != -1)
                [self.sensorsWithPendingOperations addObject:sensor];
        }
    }
}

@end
