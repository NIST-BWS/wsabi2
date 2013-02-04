//
//  WSSettingsAddSensorViewController.m
//  wsabi2
//
//  Created by Greg Fiumara on 10/17/12.
//
//

#import "WSAppDelegate.h"
#import "BWSModalityMap.h"
#import "BWSCDDeviceDefinition.h"

#import "BWSSettingsAddSensorViewController.h"

@interface BWSSettingsAddSensorViewController ()

/// Pressed the save button
- (IBAction)saveButtonPressed:(id)sender;

/// Enable the save button when fields are populated
- (IBAction)textFieldContentsDidChange:(UITextField *)sender;

/// Submodality array for the currently selected modality
@property (nonatomic, strong) NSMutableArray *submodalitiesForSelectedType;

@end

@implementation BWSSettingsAddSensorViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    [saveButton setEnabled:NO];
    [[self navigationItem] setRightBarButtonItem:saveButton];
    [[self navigationItem] setTitle:kWSSettingsAddSensorVCTitle];
    
    [self setSubmodalitiesForSelectedType:[[NSMutableArray alloc] init]];
    [[self submodalitiesForSelectedType] addObjectsFromArray:[BWSModalityMap captureTypesForModality:[[self pickerView] selectedRowInComponent:kWSSettingsAddSensorVCModalityComponent]]];
    [[self pickerView] reloadComponent:kWSSettingsAddSensorVCSubmodalityComponent];
}

#pragma mark - Events

- (IBAction)saveButtonPressed:(id)sender
{
    NSManagedObjectContext *moc = [(WSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *deviceEntity = [NSEntityDescription entityForName:kBWSEntityDeviceDefinition inManagedObjectContext:moc];
    BWSCDDeviceDefinition *device = [[BWSCDDeviceDefinition alloc] initWithEntity:deviceEntity insertIntoManagedObjectContext:moc];
    
    [device setItem:nil];
    [device setName:[[self nameField] text]];
    [device setUri:[[self addressField] text]];
    [device setModalities:[BWSModalityMap stringForModality:[[self pickerView] selectedRowInComponent:kWSSettingsAddSensorVCModalityComponent]]];
    WSSensorCaptureType submodality = [[self.submodalitiesForSelectedType objectAtIndex:
                                        [[self pickerView] selectedRowInComponent:kWSSettingsAddSensorVCSubmodalityComponent]] intValue];
    [device setSubmodalities:[BWSModalityMap stringForCaptureType:submodality]];
    
    // Parameter dictionary (as per DeviceSetupController)
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setObject:device.modalities forKey:@"modality"];
    [params setObject:[BWSModalityMap parameterNameForCaptureType:submodality] forKey:@"submodality"];
    [device setParameterDictionary:[NSKeyedArchiver archivedDataWithRootObject:params]];
    
    // Persist
    [(WSAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    
    // Go back in view stack
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - PickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case kWSSettingsAddSensorVCModalityComponent:
            return ([BWSModalityMap stringForModality:row]);
        case kWSSettingsAddSensorVCSubmodalityComponent:
            return ([BWSModalityMap stringForCaptureType:[[[self submodalitiesForSelectedType] objectAtIndex:row] intValue]]);
        default:
            return (@"");
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case kWSSettingsAddSensorVCModalityComponent:
            [[self submodalitiesForSelectedType] removeAllObjects];
            [[self submodalitiesForSelectedType] addObjectsFromArray:[BWSModalityMap captureTypesForModality:[pickerView selectedRowInComponent:kWSSettingsAddSensorVCModalityComponent]]];
            [pickerView reloadComponent:kWSSettingsAddSensorVCSubmodalityComponent];
            break;
        default:
            break;
    }
}

#pragma mark - PickerView Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return (kWSSettingsAddSensorVCNumberOfComponents);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case kWSSettingsAddSensorVCModalityComponent:
            return (kModality_COUNT);
        case kWSSettingsAddSensorVCSubmodalityComponent:
            return ([[self submodalitiesForSelectedType] count]);
        default:
            return (0);
    }
}

#pragma mark - Popover Settings

- (CGSize)contentSizeForViewInPopover
{
    return (CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height));
}

#pragma mark - TextField Delegate

- (IBAction)textFieldContentsDidChange:(UITextField *)sender
{
    if (([[[self nameField] text] isEqualToString:@""] == NO) && ([[[self addressField] text] isEqualToString:@""] == NO))
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    else
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
}

@end
