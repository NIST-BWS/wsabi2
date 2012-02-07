//
//  WSDeviceSetupController.m
//  wsabi2
//
//  Created by Matt Aronoff on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSDeviceSetupController.h"

@implementation WSDeviceSetupController
@synthesize item;
@synthesize deviceDefinition;
@synthesize tableHeaderCustomView;

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

    self.tableView.tableHeaderView = self.tableHeaderCustomView;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if (self.deviceDefinition && self.deviceDefinition.name) {
        self.title = self.deviceDefinition.name;
    }
    else {
        self.title = @"New Sensor";
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
-(IBAction)doneButtonPressed:(id)sender
{
    //Do savey stuff here.
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    switch (section) {
        case 0:
            return 2; //name and address
            break;
        case 1:
            return 0; //FIXME: This should return the parameter count.
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StringCell = @"StringCell";
    static NSString *OtherCell = @"OtherCell";
    
    if (indexPath.section == 0) {
        //basic info section
        ELCTextfieldCellWide *cell = [tableView dequeueReusableCellWithIdentifier:StringCell];
        if (cell == nil) {
            cell = [[ELCTextfieldCellWide alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        //Disables UITableViewCell from accidentally becoming selected.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.leftLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.rightTextField.font = [UIFont systemFontOfSize:15];
        cell.rightTextField.placeholder = @"";

        if (indexPath.row == 0) {
            cell.leftLabel.text = @"Network Address";
            if (self.deviceDefinition) {
                cell.rightTextField.text = self.deviceDefinition.uri;
            }
            cell.rightTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.rightTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        else if (indexPath.row == 1) {
            cell.leftLabel.text = @"Name";
            if (self.deviceDefinition) {
                cell.rightTextField.text = self.deviceDefinition.name;
            }
        }
        return cell;

    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OtherCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OtherCell];
        }
        
        // Configure the cell...

        return cell;

    }    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark ELCTextFieldCellDelegate Methods

-(void)textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
    
    //	if(indexPath.row < [labels count]-1) {
    //		NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    //		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder];
    //		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //	}
    //	
    //	else {
    //        
    //		[[(ELCTextfieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] rightTextField] resignFirstResponder];
    //	}
}

- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string {
    
	NSLog(@"See input: %@ from section: %d row: %d, should update models appropriately", string, indexPath.section, indexPath.row);
    
    if (indexPath.section == 0) {
        //These are all string cells
        if (indexPath.row == 0) {
            //update the uri
            if(self.deviceDefinition) self.deviceDefinition.uri = string;
        }
        else if (indexPath.row == 1) {
            //update the name and the window title.
            self.title = string;
            if(self.deviceDefinition) self.deviceDefinition.name = string;
        }
    }
}



@end
