//
//  WSBiographicalDataController.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSBiographicalDataController.h"

@implementation WSBiographicalDataController
@synthesize bioDataTable;
@synthesize person;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Biographical Info";
    
    //Initialize the arrays to hold picker string values.
    genderStrings = [NSArray arrayWithObjects:@"Male",@"Female",@"Unknown", nil];
    hairColorStrings = [NSArray arrayWithObjects:@"Black",@"Brown",@"Blonde",@"Red",nil];
    raceStrings = [NSArray arrayWithObjects:@"Unknown",@"Asian",@"Black",@"Native American",@"Caucasian",@"Latino",nil];
    eyeColorStrings = [NSArray arrayWithObjects:@"Brown",@"Blue",@"Green",nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Property setters
-(void) setPerson:(WSCDPerson *)newPerson 
{
    person = newPerson;
    
    //unpack the contained arrays
    if (person.aliases) {
        aliases = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.person.aliases]];
    }
    else {
        aliases = [[NSMutableArray alloc] init];
    }
    if (person.datesOfBirth) {
        datesOfBirth = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.person.datesOfBirth]];
    }
    else {
        datesOfBirth = [[NSMutableArray alloc] init];
    }
    if (person.placesOfBirth) {
        placesOfBirth = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.person.placesOfBirth]];
    }
    else {
        placesOfBirth = [[NSMutableArray alloc] init];
    }
}

#pragma mark - TableView data source/delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kSectionBasic:
            return 7; //first, middle, last, other, alias, DOB, POB
            break;
        case kSectionGender:
            return 1;
            break;
        case kSectionDescriptive: //hair, race, eyes, height, weight
            return 5;
            break;
        default:
            return 0;
            break;
    }
}

// Customize the appearance of table view cells.
////FIXME: This should be more flexible about different cell arrangements!
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //NSLog(@"Index path for selected row is (%d,%d)",selectedIndex.section, selectedIndex.row);
//    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    //if there are 0 items, use 1 row. Otherwise, fit to the number of items.
//    int numRows = MAX(1, ceil([person.items count] / 5.0)); 
//    
//    NSLog(@"Row %d should have %d rows",indexPath.row, numRows);
//    
//    if ([indexPath compare:selectedIndex] == NSOrderedSame) {
//        return 264 + (124.0 * numRows);
//    }
//    else return 40.0 + (124.0 * numRows);
//}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StringCell = @"StringCell"; 
    static NSString *DatePickerCell = @"DateCell"; 
    static NSString *SimplePickerCell = @"SimplePickerCell"; 
        
    if (indexPath.section == kSectionBasic) {
        //These are all string cells
        if (indexPath.row != kRowDOB) {
            ELCTextfieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
            if (cell == nil) {
                cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
            }
            //Common setup for all text cells
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            //start with an empty cell
            cell.rightTextField.text = nil;
            cell.rightTextField.placeholder = @"";
            
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //Based on which row we're filling, pull up the correct data from the current person.
            switch (indexPath.row) {
                case kRowFirstName:
                    cell.leftLabel.text = @"First Name";
                    cell.rightTextField.text = self.person.firstName;
                    break;
                case kRowMiddleName:
                    cell.leftLabel.text = @"Middle Name";
                    cell.rightTextField.text = self.person.middleName;
                    break;
                case kRowLastName:
                    cell.leftLabel.text = @"Last Name";
                    cell.rightTextField.text = self.person.lastName;
                    break;
                case kRowOtherName:
                    cell.leftLabel.text = @"Other Name";
                    cell.rightTextField.text = self.person.otherName;
                    break;
                case kRowAlias:
                    //For now, we're only allowing one alias.
                    cell.leftLabel.text = @"Alias";
                    if([aliases count] > 0) cell.rightTextField.text = [aliases objectAtIndex:0];
                    break;
                case kRowPOB:
                    //For now, we're only allowing one place of birth
                    cell.leftLabel.text = @"Place of Birth";
                    if([placesOfBirth count] > 0) cell.rightTextField.text = [placesOfBirth objectAtIndex:0];
                    break;

                default:
                    break;
            }
   
            return cell;
        }
        
        else {
            //For now, we're only allowing one date of birth.
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:DatePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:DatePickerCell];
            }
            
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            
            cell.textLabel.text = @"DOB";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterMediumStyle;
            cell.detailTextLabel.text = ([datesOfBirth count] > 0) ? [formatter stringFromDate:[datesOfBirth objectAtIndex:0]] : @"Tap to enter";
            return cell;
        }
        
    }
    else if (indexPath.section == kSectionGender) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:DatePickerCell];
        }
        //set up font sizes to match the ELCTextFieldCells
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];

        cell.textLabel.text = @"Gender";
        cell.detailTextLabel.text = self.person.gender ? self.person.gender : @"Tap to choose";
        return cell;
    }
    
    else if (indexPath.section == kSectionDescriptive) {
        if (indexPath.row == kRowHair) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:DatePickerCell];
            }
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];

            cell.textLabel.text = @"Hair color";
            cell.detailTextLabel.text = self.person.hairColor ? self.person.hairColor : @"Tap to choose";
            return cell;
        }
        else if (indexPath.row == kRowRace) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:DatePickerCell];
            }
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];

            cell.textLabel.text = @"Race";
            cell.detailTextLabel.text = self.person.race ? self.person.race : @"Tap to choose";
            return cell;
        }
        else if (indexPath.row == kRowEyes) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:DatePickerCell];
            }
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];

            cell.textLabel.text = @"Eye color";
            cell.detailTextLabel.text = self.person.eyeColor ? self.person.eyeColor : @"Tap to choose";
            return cell;
        }
        else if (indexPath.row == kRowHeight) {
            ELCTextfieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
            if (cell == nil) {
                cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
            }
            cell.indexPath = indexPath;
            cell.delegate = self;
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.leftLabel.text = @"Height";
            cell.rightTextField.text = self.person.height;
            cell.rightTextField.placeholder = @"";
            return cell;
        }
        else if (indexPath.row == kRowWeight) {
            ELCTextfieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
            if (cell == nil) {
                cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
            }
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.leftLabel.text = @"Weight";
            cell.rightTextField.text = self.person.weight;
            cell.rightTextField.placeholder = @"";
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }

    }
    
    return nil;
    
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
    //Certain cells need to respond to selection by displaying an additional chooser, etc.
    if (indexPath.section == kSectionBasic && indexPath.row == kRowDOB) {
        //For now, we're only allowing one date of birth.
        ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Date of Birth" 
                                                                      datePickerMode:UIDatePickerModeDate 
                                                                        selectedDate:[NSDate date] 
                                                                              target:self action:@selector(dobSelected:element:) origin:self.view];
        picker.neverPresentInPopover = YES; //only show this in an action sheet.
        [picker showActionSheetPicker];
    }
    else if (indexPath.section == kSectionGender) {
        //FIXME: Get the correct initial index from the person record.
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Gender"
                                                                                    rows:genderStrings 
                                                                        initialSelection:0
                                                                                  target:self
                                                                            sucessAction:@selector(genderSelected:element:) 
                                                                            cancelAction:nil 
                                                                                  origin:self.view];
        picker.neverPresentInPopover = YES; //only show this in an action sheet.
        [picker showActionSheetPicker];
    }
    
    else if (indexPath.section == kSectionDescriptive) {
        if (indexPath.row == kRowHair) {
            //FIXME: Get the correct initial index from the person record.
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Hair Color"
                                                                                        rows:hairColorStrings 
                                                                            initialSelection:0
                                                                                      target:self
                                                                                sucessAction:@selector(hairColorSelected:element:) 
                                                                                cancelAction:nil 
                                                                                      origin:self.view];
            picker.neverPresentInPopover = YES; //only show this in an action sheet.
            [picker showActionSheetPicker];
         }
        else if (indexPath.row == kRowRace) {
            //FIXME: Get the correct initial index from the person record.
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Race"
                                                                                        rows:raceStrings 
                                                                            initialSelection:0
                                                                                      target:self
                                                                                sucessAction:@selector(raceSelected:element:) 
                                                                                cancelAction:nil 
                                                                                      origin:self.view];
            picker.neverPresentInPopover = YES; //only show this in an action sheet.
            [picker showActionSheetPicker];
         }
        else if (indexPath.row == kRowEyes) {
            //FIXME: Get the correct initial index from the person record.
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Eye Color"
                                                                                        rows:eyeColorStrings 
                                                                            initialSelection:0
                                                                                      target:self
                                                                                sucessAction:@selector(eyeColorSelected:element:) 
                                                                                cancelAction:nil 
                                                                                      origin:self.view];
            picker.neverPresentInPopover = YES; //only show this in an action sheet.
            [picker showActionSheetPicker];
        }
        
    }

    //deselect the row afterwards
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    if (indexPath.section == kSectionBasic) {
        //These are all string cells
        if (indexPath.row != kRowDOB) {
            //Based on which row we're filling, save the correct data from the current person.
            switch (indexPath.row) {
                case kRowFirstName:
                    self.person.firstName = string;
                    break;
                case kRowMiddleName:
                    self.person.middleName = string;
                    break;
                case kRowLastName:
                    self.person.lastName = string;
                    break;
                case kRowOtherName:
                    self.person.otherName = string;
                    break;
                case kRowAlias:
                    //For now, we're only allowing one alias.
                    if ([aliases count] > 0) {
                        [aliases replaceObjectAtIndex:0 withObject:string];
                    }
                    else {
                        [aliases addObject:string];
                    }
                    //save the array back to the person record.
                    self.person.aliases = [NSKeyedArchiver archivedDataWithRootObject:aliases];
                    break;
                case kRowPOB:
                    //For now, we're only allowing one place of birth
                    if ([placesOfBirth count] > 0) {
                        [placesOfBirth replaceObjectAtIndex:0 withObject:string];
                    }
                    else {
                        [placesOfBirth addObject:string];
                    }
                    //save the array back to the person record.
                    self.person.placesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:placesOfBirth];
                    break;
                    
                default:
                    break;
            }
            
        }
        
    }
    else if (indexPath.section == kSectionDescriptive) {
        if (indexPath.row == kRowHeight) {
            self.person.height = string;
        }
        else if (indexPath.row == kRowWeight) {
            self.person.weight = string;
        }
        
    }
}

#pragma mark - Picker handler methods
- (void)dobSelected:(NSDate *)selectedDate element:(id)element {
    if ([datesOfBirth count] > 0) {
        [datesOfBirth replaceObjectAtIndex:0 withObject:selectedDate];
    }
    else {
        [datesOfBirth addObject:selectedDate];
    }
    
    //save the array back to the person record.
    self.person.datesOfBirth = [NSKeyedArchiver archivedDataWithRootObject:datesOfBirth];
    
    //reload UI
    [self.bioDataTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kRowDOB inSection:kSectionBasic]]
                             withRowAnimation:UITableViewRowAnimationFade];
}

-(void) genderSelected:(NSNumber *)selectedIndex element:(id)element
{
    self.person.gender = [genderStrings objectAtIndex:[selectedIndex intValue]]; 
    //reload UI
    [self.bioDataTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kRowGender inSection:kSectionGender]]
                             withRowAnimation:UITableViewRowAnimationFade];

}

-(void) hairColorSelected:(NSNumber *)selectedIndex element:(id)element
{
    self.person.hairColor = [hairColorStrings objectAtIndex:[selectedIndex intValue]]; 
    //reload UI
    [self.bioDataTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kRowHair inSection:kSectionDescriptive]]
                             withRowAnimation:UITableViewRowAnimationFade];
}

-(void) raceSelected:(NSNumber *)selectedIndex element:(id)element
{
    self.person.race = [raceStrings objectAtIndex:[selectedIndex intValue]]; 
    //reload UI
    [self.bioDataTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kRowRace inSection:kSectionDescriptive]]
                             withRowAnimation:UITableViewRowAnimationFade];
}

-(void) eyeColorSelected:(NSNumber *)selectedIndex element:(id)element
{
    self.person.eyeColor = [eyeColorStrings objectAtIndex:[selectedIndex intValue]]; 
    //reload UI
    [self.bioDataTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kRowEyes inSection:kSectionDescriptive]]
                             withRowAnimation:UITableViewRowAnimationFade];

}


@end
