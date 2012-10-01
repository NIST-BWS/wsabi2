//
//  WSSubmodalityChooser.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
 
//

#import "WSSubmodalityChooserController.h"

@implementation WSSubmodalityChooserController
@synthesize modality;
@synthesize item;
@synthesize currentButton;
@synthesize tapBehindViewRecognizer;

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
    
    self.title = [WSModalityMap stringForModality:self.modality];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //If we have a valid stored modality and it matches, show the "keep it" button.
    if (self.item.managedObjectContext && self.item.submodality 
        && (self.modality == [WSModalityMap modalityForString:self.item.modality])
        && self.modality != kCaptureTypeNotSet
        ) {
        self.currentButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Keep \"%@\"",self.item.submodality]
                                                              style:UIBarButtonItemStyleDone
                                                             target:self action:@selector(currentButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.currentButton;
    }

    
}

- (void)viewDidUnload
{
    [self setTapBehindViewRecognizer:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Add recognizer to detect taps outside of the modal view
    [[self tapBehindViewRecognizer] setCancelsTouchesInView:NO];
    [[self tapBehindViewRecognizer] setNumberOfTapsRequired:1];
    [[[self view] window] addGestureRecognizer:[self tapBehindViewRecognizer]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Remove recognizer when view isn't visible
    [[[self view] window] removeGestureRecognizer:[self tapBehindViewRecognizer]];
    
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

#pragma mark - Property getters/setters
-(void) setModality:(WSSensorModalityType)newModality
{
    modality = newModality;
    submodalities = [WSModalityMap captureTypesForModality:modality];
}

-(IBAction) currentButtonPressed:(id)sender
{
    //Push a new controller to choose the device.
    WSDeviceChooserController *subChooser = [[WSDeviceChooserController alloc] initWithNibName:@"WSDeviceChooserController" bundle:nil];
    subChooser.item = self.item; //pass the data object to the next step in the walkthrough
    subChooser.modality = [WSModalityMap modalityForString:self.item.modality];
    subChooser.submodality = [WSModalityMap captureTypeForString:self.item.submodality]; 
    
    [self.navigationController pushViewController:subChooser animated:YES];
    
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
            [self dismissModalViewControllerAnimated:YES];
        }
    }
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
        //enable touch logging for new cells
        [cell startAutomaticGestureLogging:YES];
    }
    
    // Configure the cell...
    cell.textLabel.text = [WSModalityMap stringForCaptureType:[[submodalities objectAtIndex:indexPath.row] intValue]];
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
    //Push a new controller to choose the device.
    WSDeviceChooserController *subChooser = [[WSDeviceChooserController alloc] initWithNibName:@"WSDeviceChooserController" bundle:nil];
    subChooser.modality = self.modality;
    subChooser.submodality = [[submodalities objectAtIndex:indexPath.row] intValue];
    NSLog(@"Walkthrough setting submodality to %@",[WSModalityMap stringForCaptureType:subChooser.submodality]);

//    //set the item's submodality
//    self.item.submodality = [WSModalityMap stringForCaptureType:[[submodalities objectAtIndex:indexPath.row] intValue]];
    
    subChooser.item = self.item; //pass the data object to the next step in the walkthrough
    
    [self.navigationController pushViewController:subChooser animated:YES];
}

@end
