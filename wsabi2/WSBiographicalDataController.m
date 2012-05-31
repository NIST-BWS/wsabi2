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
@synthesize delegate;

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
    genderStrings = [NSArray arrayWithObjects:@"",@"Male",@"Female",@"Unknown", nil];
    hairColorStrings = [NSArray arrayWithObjects:@"",@"Black",@"Brown",@"Blonde",@"Red",nil];
    raceStrings = [NSArray arrayWithObjects:@"",@"Unknown",@"Asian",@"Black",@"Native American",@"Caucasian",@"Latino",nil];
    eyeColorStrings = [NSArray arrayWithObjects:@"",@"Brown",@"Blue",@"Green",nil];
    
    //enable touch logging
    [self.view startAutomaticGestureLogging:YES];
    
    //listen for the keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) 
                                                 name:UIKeyboardDidShowNotification object:nil]; 

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

-(CGSize) contentSizeForViewInPopover
{
    return CGSizeMake(320, 600);
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

#pragma mark - Notification handlers
-(void) keyboardDidShow:(NSNotification*)notification
{
    
    //find first responder, scroll it to visible.
    UIView *fr = [self.bioDataTable findFirstResponder];
    [self.bioDataTable scrollRectToVisible:[self.bioDataTable convertRect:fr.frame fromView:fr.superview] animated:YES];
}

#pragma mark - TableView data source/delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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
        case kSectionNotes:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

// Customize the appearance of table view cells.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionNotes && indexPath.row == kRowNotes) {
        return 200;
    }
    else return self.bioDataTable.rowHeight;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kSectionNotes) {
        return @"Notes";
    }
    else return nil;

}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StringCell = @"StringCell"; 
    static NSString *DatePickerCell = @"DateCell"; 
    static NSString *SimplePickerCell = @"SimplePickerCell"; 
    static NSString *TextViewCell = @"TextViewCell";
        
    if (indexPath.section == kSectionBasic) {
        //These are all string cells
        if (indexPath.row != kRowDOB) {
            ELCTextfieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
            if (cell == nil) {
                cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
                //connect the text field delegate so we can log the text field itself.
                //cell.rightTextField.delegate = self;
            }
            //Common setup for all text cells
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            //start with an empty cell with no accessory
            cell.leftLabel.font = [UIFont systemFontOfSize:14];
            cell.rightTextField.text = nil;
            cell.rightTextField.placeholder = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.rightTextField.keyboardType = UIKeyboardTypeDefault;
            
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //Based on which row we're filling, pull up the correct data from the current person.
            switch (indexPath.row) {
                case kRowFirstName:
                    cell.leftLabel.text = @"First Name";
                    cell.rightTextField.text = self.person.firstName;
                    cell.rightTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case kRowMiddleName:
                    cell.leftLabel.text = @"Middle Name";
                    cell.rightTextField.text = self.person.middleName;
                    cell.rightTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case kRowLastName:
                    cell.leftLabel.text = @"Last Name";
                    cell.rightTextField.text = self.person.lastName;
                    cell.rightTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case kRowOtherName:
                    cell.leftLabel.text = @"Other Name";
                    cell.rightTextField.text = self.person.otherName;
                    cell.rightTextField.returnKeyType = UIReturnKeyNext;                    
                    break;
                case kRowAlias:
                    //For now, we're only allowing one alias.
                    cell.leftLabel.text = @"Alias";
                    if([aliases count] > 0) cell.rightTextField.text = [aliases objectAtIndex:0];
                    cell.rightTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case kRowPOB:
                    //For now, we're only allowing one place of birth
                    cell.leftLabel.text = @"Place of Birth";
                    if([placesOfBirth count] > 0) cell.rightTextField.text = [placesOfBirth objectAtIndex:0];
                    cell.rightTextField.returnKeyType = UIReturnKeyDone;
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
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
            }
            
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell.textLabel.text = @"DOB";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterMediumStyle;
            cell.detailTextLabel.text = ([datesOfBirth count] > 0) ? [formatter stringFromDate:[datesOfBirth objectAtIndex:0]] : nil;
            return cell;
        }
        
    }
    else if (indexPath.section == kSectionGender) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:SimplePickerCell];
            //enable touch logging for new cells
            [cell startAutomaticGestureLogging:YES];
        }
        //set up font sizes to match the ELCTextFieldCells
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        cell.textLabel.text = @"Gender";
        cell.detailTextLabel.text = self.person.gender;
        return cell;
    }
    
    else if (indexPath.section == kSectionDescriptive) {
        if (indexPath.row == kRowHair) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:SimplePickerCell];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
            }
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell.textLabel.text = @"Hair color";
            cell.detailTextLabel.text = self.person.hairColor;
            return cell;
        }
        else if (indexPath.row == kRowRace) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:SimplePickerCell];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
            }
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell.textLabel.text = @"Race";
            cell.detailTextLabel.text = self.person.race;
            return cell;
        }
        else if (indexPath.row == kRowEyes) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:SimplePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:SimplePickerCell];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
            }
            //set up font sizes to match the ELCTextFieldCells
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell.textLabel.text = @"Eye color";
            cell.detailTextLabel.text = self.person.eyeColor;
            return cell;
        }
        else if (indexPath.row == kRowHeight) {
            ELCTextfieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
            if (cell == nil) {
                cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
                //connect the text field delegate so we can log the text field itself.
                //cell.rightTextField.delegate = self;
            }
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.leftLabel.font = [UIFont systemFontOfSize:14];
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.leftLabel.text = @"Height";
            cell.rightTextField.text = self.person.height;
            cell.rightTextField.placeholder = @"";
            cell.rightTextField.returnKeyType = UIReturnKeyNext;                    
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.rightTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

            
            return cell;
        }
        else if (indexPath.row == kRowWeight) {
            ELCTextfieldCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
            if (cell == nil) {
                cell = [[ELCTextfieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StringCell];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];
                //connect the text field delegate so we can log the text field itself.
                //cell.rightTextField.delegate = self;
            }
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.leftLabel.font = [UIFont systemFontOfSize:14];
            cell.leftLabel.text = @"Weight";
            cell.rightTextField.text = self.person.weight;
            cell.rightTextField.placeholder = @"";
            cell.rightTextField.returnKeyType = UIReturnKeyDone;                    
            //Disables UITableViewCell from accidentally becoming selected.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.rightTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;

            return cell;
        }

    }
    else if (indexPath.section == kSectionNotes) {
        if (indexPath.row == kRowNotes) {
            UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:TextViewCell];
            UITextView *textView;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:TextViewCell];
                textView = [[UITextView alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 4, 2)];
                textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                textView.delegate = self;
                textView.font = [UIFont systemFontOfSize:17];
                textView.backgroundColor = [UIColor clearColor];
                
                [cell.contentView addSubview:textView];
                //enable touch logging for new cells
                [cell startAutomaticGestureLogging:YES];

            }
            else {
                for (int i = 0; i < [cell.contentView.subviews count]; i++) {
                    UIView *v = [cell.contentView.subviews objectAtIndex:i];
                    if ([v isKindOfClass:[UITextView class]]) {
                        textView = (UITextView*)v;
                        break; //stop looking
                    }
                } 
            }
            textView.text = self.person.notes;  

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
    BOOL didShowActionSheet = NO;
    //Certain cells need to respond to selection by displaying an additional chooser, etc.
    if (indexPath.section == kSectionBasic && indexPath.row == kRowDOB) {
        //For now, we're only allowing one date of birth.
        ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Date of Birth" 
                                                                      datePickerMode:UIDatePickerModeDate 
                                                                        selectedDate:[NSDate date] 
                                                                              target:self 
                                                                              action:@selector(dobSelected:element:) 
                                                                              origin:self.view];
        
        picker.neverPresentInPopover = YES; //only show this in an action sheet.
        [picker showActionSheetPicker];
        picker.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-3153600000]; //about 100 years ago.
        picker.datePicker.maximumDate = [NSDate date]; //we're unlikely to get prints from someone born in the future.
        didShowActionSheet = YES;
    }
    else if (indexPath.section == kSectionGender) {
        int initialPosition = self.person.gender ? [genderStrings indexOfObject:self.person.gender] : 0;
        ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Gender"
                                                                                    rows:genderStrings 
                                                                        initialSelection:initialPosition
                                                                                  target:self
                                                                            sucessAction:@selector(genderSelected:element:) 
                                                                            cancelAction:nil 
                                                                                  origin:self.view];
        picker.neverPresentInPopover = YES; //only show this in an action sheet.
        [picker showActionSheetPicker];
        didShowActionSheet = YES;
    }
    
    else if (indexPath.section == kSectionDescriptive) {
        if (indexPath.row == kRowHair) {
            int initialPosition = self.person.hairColor ? [hairColorStrings indexOfObject:self.person.hairColor] : 0;
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Hair Color"
                                                                                        rows:hairColorStrings 
                                                                            initialSelection:initialPosition
                                                                                      target:self
                                                                                sucessAction:@selector(hairColorSelected:element:) 
                                                                                cancelAction:nil 
                                                                                      origin:self.view];
            picker.neverPresentInPopover = YES; //only show this in an action sheet.
            [picker showActionSheetPicker];
            didShowActionSheet = YES;
         }
        else if (indexPath.row == kRowRace) {
            int initialPosition = self.person.race ? [raceStrings indexOfObject:self.person.race] : 0;
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Race"
                                                                                        rows:raceStrings 
                                                                            initialSelection:initialPosition
                                                                                      target:self
                                                                                sucessAction:@selector(raceSelected:element:) 
                                                                                cancelAction:nil 
                                                                                      origin:self.view];
            picker.neverPresentInPopover = YES; //only show this in an action sheet.
            [picker showActionSheetPicker];
            didShowActionSheet = YES;
         }
        else if (indexPath.row == kRowEyes) {
            int initialPosition = self.person.eyeColor ? [eyeColorStrings indexOfObject:self.person.eyeColor] : 0;
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"Eye Color"
                                                                                        rows:eyeColorStrings 
                                                                            initialSelection:initialPosition
                                                                                      target:self
                                                                                sucessAction:@selector(eyeColorSelected:element:) 
                                                                                cancelAction:nil 
                                                                                      origin:self.view];
            picker.neverPresentInPopover = YES; //only show this in an action sheet.
            [picker showActionSheetPicker];
            didShowActionSheet = YES;
        }
        
    }

    //Log the action sheet (not shown in a popover)
    if (didShowActionSheet) {
        [[aTableView cellForRowAtIndexPath:indexPath] logActionSheetShown:NO];
    }

    //deselect the row afterwards
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ELCTextFieldCellDelegate Methods
-(void) textFieldDidBeginEditingWithIndexPath:(NSIndexPath *)indexPath
{
    ELCTextfieldCell *textCell = (ELCTextfieldCell*)[self.bioDataTable cellForRowAtIndexPath:indexPath];
    
    //make sure this cell is visible
    [self.bioDataTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
    //Log this.
    if (textCell)
        [[textCell rightTextField] logTextFieldStarted:indexPath];
}

-(void) textFieldDidEndEditingWithIndexPath:(NSIndexPath *)indexPath
{
    ELCTextfieldCell *textCell = (ELCTextfieldCell*)[self.bioDataTable cellForRowAtIndexPath:indexPath];
    
    [self updateTextLabelAtIndexPath:indexPath string:[textCell.rightTextField text]];
    
    //Log this.
    if (textCell)
        [[textCell rightTextField] logTextFieldEnded:indexPath];
}


-(void) textFieldDidReturnWithIndexPath:(NSIndexPath*)indexPath {
    
    ELCTextfieldCell *textCell = (ELCTextfieldCell*)[self.bioDataTable cellForRowAtIndexPath:indexPath];
    
//    //Log this.
//    [[textCell rightTextField] logTextFieldEnded:indexPath];
    
    int rowIndex = indexPath.row;
	while(rowIndex < [self tableView:self.bioDataTable numberOfRowsInSection:indexPath.section] - 1) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:rowIndex+1 inSection:indexPath.section];
        //If there's another text field in this section, choose it.
        if([[self.bioDataTable cellForRowAtIndexPath:path] isKindOfClass:[ELCTextfieldCell class]])
        {    
            [[(ELCTextfieldCell*)[self.bioDataTable cellForRowAtIndexPath:path] rightTextField] becomeFirstResponder]; 
            [self.bioDataTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return; //don't resign first responder.
        }
        rowIndex++; //if we didn't find anything, keep going until we hit the end of the section.
	}
	//otherwise, just resign first responder.
	[[textCell rightTextField] resignFirstResponder];
        
}

- (void)updateTextLabelAtIndexPath:(NSIndexPath*)indexPath string:(NSString*)string {
    
	//NSLog(@"See input: %@ from section: %d row: %d, should update models appropriately", string, indexPath.section, indexPath.row);
    
    if (indexPath.section == kSectionBasic) {
        //These are all string cells
        if (indexPath.row != kRowDOB) {
            //Based on which row we're filling, save the correct data from the current person.
            switch (indexPath.row) {
                case kRowFirstName:
                    self.person.firstName = string;
                    [delegate didUpdateDisplayName]; //update the UI
                    break;
                case kRowMiddleName:
                    self.person.middleName = string;
                    [delegate didUpdateDisplayName]; //update the UI
                    break;
                case kRowLastName:
                    self.person.lastName = string;
                    [delegate didUpdateDisplayName]; //update the UI
                    break;
                case kRowOtherName:
                    self.person.otherName = string;
                    [delegate didUpdateDisplayName]; //update the UI
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

-(void) pickerDidCancel
{
    
}

#pragma mark - UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField)
        [textField logTextFieldStarted:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField)
        [textField logTextFieldEnded:nil];
}

#pragma mark - UITextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView) 
        [textView logTextViewStarted:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView)
        self.person.notes = textView.text;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView)
        [textView logTextViewEnded:nil];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView logScrollStarted];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView logScrollChanged];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView logScrollEnded];
}

@end
