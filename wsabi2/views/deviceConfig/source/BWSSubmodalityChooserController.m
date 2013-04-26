// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSDDLog.h"

#import "BWSSubmodalityChooserController.h"

@implementation BWSSubmodalityChooserController
@synthesize modality;
@synthesize item;
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
    
    self.title = [BWSModalityMap stringForModality:self.modality];
    [self.view setAccessibilityLabel:@"Device Walkthrough -- Submodality View"];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)]];
    
    //If we have a valid stored modality and it matches, show the "keep it" button.
    if (self.item.managedObjectContext && self.item.submodality 
        && (self.modality == [BWSModalityMap modalityForString:self.item.modality])
        && self.modality != kCaptureTypeNotSet
        ) {
        self.currentButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Keep \"%@\"",self.item.submodality]
                                                              style:UIBarButtonItemStyleDone
                                                             target:self action:@selector(currentButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.currentButton;
    }

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view logViewPresented];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self tableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeScroll];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view logViewDismissed];
    [[self tableView] stopLoggingBWSInterfaceEvents];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Property getters/setters
-(void) setModality:(WSSensorModalityType)newModality
{
    modality = newModality;
    submodalities = [BWSModalityMap captureTypesForModality:modality];
}

-(IBAction) currentButtonPressed:(id)sender
{
    //Push a new controller to choose the device.
    BWSDeviceChooserController *subChooser = [[BWSDeviceChooserController alloc] initWithNibName:@"BWSDeviceChooserController" bundle:nil];
    subChooser.item = self.item; //pass the data object to the next step in the walkthrough
    subChooser.modality = [BWSModalityMap modalityForString:self.item.modality];
    subChooser.submodality = [BWSModalityMap captureTypeForString:self.item.submodality]; 
    
    [self.navigationController pushViewController:subChooser animated:YES];
    
}

- (void)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [submodalities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [BWSModalityMap stringForCaptureType:[[submodalities objectAtIndex:indexPath.row] intValue]];
    cell.accessibilityLabel = cell.textLabel.text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==  UITableViewCellEditingStyleDelete)
        [[tableView cellForRowAtIndexPath:indexPath] stopLoggingBWSInterfaceEvents];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Push a new controller to choose the device.
    BWSDeviceChooserController *subChooser = [[BWSDeviceChooserController alloc] initWithNibName:@"BWSDeviceChooserController" bundle:nil];
    subChooser.modality = self.modality;
    subChooser.submodality = [[submodalities objectAtIndex:indexPath.row] intValue];
    DDLogBWSVerbose(@"Walkthrough setting submodality to %@",[BWSModalityMap stringForCaptureType:subChooser.submodality]);

//    //set the item's submodality
//    self.item.submodality = [WSModalityMap stringForCaptureType:[[submodalities objectAtIndex:indexPath.row] intValue]];
    
    subChooser.item = self.item; //pass the data object to the next step in the walkthrough
    
    [self.navigationController pushViewController:subChooser animated:YES];
}

@end
