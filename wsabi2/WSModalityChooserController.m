//
//  WSModalityChooserController.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSModalityChooserController.h"

@implementation WSModalityChooserController
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
    
    self.title = @"Capture type";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if (self.item.managedObjectContext && self.item.modality) {
        self.currentButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Keep \"%@\"",self.item.modality]
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
    [self dismissModalViewControllerAnimated:YES];
    //post a notification to hide the device chooser and return to the previous state
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:item forKey:kDictKeyTargetItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];
}

-(IBAction) currentButtonPressed:(id)sender
{
    //Push a new controller to choose the submodality.
    WSSubmodalityChooserController *subChooser = [[WSSubmodalityChooserController alloc] initWithNibName:@"WSSubmodalityChooserController" bundle:nil];
    subChooser.modality = [WSModalityMap modalityForString:self.item.modality];

    subChooser.item = self.item; //pass the data object
    
    [self.navigationController pushViewController:subChooser animated:YES];

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
    return kModality_COUNT;
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
    cell.textLabel.text = [WSModalityMap stringForModality:indexPath.row];
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
    //Push a new controller to choose the submodality.
    WSSubmodalityChooserController *subChooser = [[WSSubmodalityChooserController alloc] initWithNibName:@"WSSubmodalityChooserController" bundle:nil];
    subChooser.modality = indexPath.row;
    
//    //set the item's modality string to match the chosen object
//    self.item.modality = [WSModalityMap stringForModality:indexPath.row];
    
    subChooser.item = self.item; //pass the data object
    
    [self.navigationController pushViewController:subChooser animated:YES];
}

@end
