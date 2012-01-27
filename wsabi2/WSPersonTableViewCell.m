//
//  WSItemGridCell.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSPersonTableViewCell.h"

#import "WSAppDelegate.h"

@implementation WSPersonTableViewCell
@synthesize person;
@synthesize itemGridView;
@synthesize editButton, addButton, deleteButton, duplicateRowButton;
@synthesize customSelectedBackgroundView;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    if (!initialLayoutComplete) {
        
        deletableItem = -1;
        
        //configure UI elements
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-highlighted"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateDisabled];
        
        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-highlighted"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateDisabled];
        
        self.customSelectedBackgroundView.image = [[UIImage imageNamed:@"personcell-bg-selected"] stretchableImageWithLeftCapWidth:20 topCapHeight:170];
        
        //new rows that start selected need to have the active controls' highlights turned off.
        self.duplicateRowButton.highlighted = !self.selected;
        self.addButton.highlighted = !self.selected;
        self.editButton.highlighted = !self.selected;
        self.deleteButton.highlighted = !self.selected;
        
        //update the local data information from Core Data
        [self updateData];
        
        //configure and reload the grid view
        //NOTE: The grid view has to be initialized here, because at least for the moment, GMGridView doesn't have an initWithCoder implementation.
        self.itemGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
        self.itemGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        float spacing = 12;
        self.itemGridView.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]; 
        self.itemGridView.style = GMGridViewStylePush;
        self.itemGridView.itemSpacing = spacing;
        self.itemGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, 92, spacing, spacing);
        self.itemGridView.centerGrid = NO;
        self.itemGridView.actionDelegate = self;
        self.itemGridView.sortingDelegate = self;
        self.itemGridView.transformDelegate = self;
        self.itemGridView.dataSource = self;
        self.itemGridView.userInteractionEnabled = NO; //start with this disabled unless we actively set this cell to selected.
        
        [self.contentView insertSubview:self.itemGridView aboveSubview:self.customSelectedBackgroundView];


        initialLayoutComplete = YES;
    }
    
    //if this isn't the selected cell, make sure it's not in edit mode.
    if (!self.selected) {
        self.editing = NO;
    }
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    self.duplicateRowButton.highlighted = !selected;
    self.addButton.highlighted = !selected;
    self.editButton.highlighted = !selected;
    self.deleteButton.highlighted = !selected;
    
    if (selected) {
//        if (self.customSelectedBackgroundView.hidden) {
//            self.customSelectedBackgroundView.hidden = NO;
//            self.customSelectedBackgroundView.alpha = 0;
//        }

        [UIView animateWithDuration:kTableViewContentsAnimationDuration animations:^{
            self.customSelectedBackgroundView.alpha = 1.0;
            self.duplicateRowButton.alpha = 1.0;
            self.addButton.alpha = 1.0;
            self.editButton.alpha = 1.0;
            self.deleteButton.alpha = 1.0;
            self.itemGridView.frame = CGRectMake(self.itemGridView.frame.origin.x, 
                                                 128, 
                                                 self.itemGridView.frame.size.width,
                                                 self.bounds.size.height - 128 - 30); //subtract extra space from the height because of the New Person button visible at the bottom.
        }];
    }
    else {
//        //If anything is selected in the grid, deselect it.
//        if ([self.itemGridView indexPathForSelectedCell]) {
//            [self.itemGridView deselectItemsAtIndexPaths:[NSArray arrayWithObject:[self.itemGridView indexPathForSelectedCell]] animated:YES];
//        }
        [UIView animateWithDuration:kTableViewContentsAnimationDuration animations:^{
                            self.customSelectedBackgroundView.alpha = 0.0;
                            self.duplicateRowButton.alpha = 0.0;
                            self.addButton.alpha = 0.0;
                            self.editButton.alpha = 0.0;
                            self.deleteButton.alpha = 0.0;
                            self.itemGridView.frame = CGRectMake(self.itemGridView.frame.origin.x, 
                                                 12, 
                                                 self.itemGridView.frame.size.width,
                                                 self.bounds.size.height - 24); //Leave a 12-pixel border above and below
                        } 
//                         completion:^(BOOL completed) {
//                            self.customSelectedBackgroundView.hidden = YES;
//                        }
         
        ];
    }
    self.itemGridView.userInteractionEnabled = selected;
}

-(void) setPerson:(WSCDPerson *)newPerson
{
    person = newPerson;
    [self updateData];
}

-(void) setEditing:(BOOL)newEditingStatus
{
    [super setEditing:newEditingStatus];

    //make sure the edit button's in the right state.
    self.editButton.selected = newEditingStatus;

    self.itemGridView.editing = newEditingStatus;
    
//    //propogate this down to the contained grid cells
//    for (UIView *v in self.cellGridView.subviews) {
//        if ([v isKindOfClass:[WSItemGridCell class]]) {
//            //mark this cell with the same editing properties as the parent.
//            ((WSItemGridCell*)v).editing = newEditingStatus;
//        }
//    }
}

-(void) updateData
{

    NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES]];
   
    
    //get a sorted array of items
    orderedItems = [[self.person.items sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
}

-(void) reloadItemGridAnimated:(BOOL)inOrOut
{
    float part1Duration = kFastFadeAnimationDuration;
    float part2Duration = kMediumFadeAnimationDuration;
    
    //animate a reload of the data
    [UIView animateWithDuration:part1Duration
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn
                     animations:^{
                         self.itemGridView.transform = inOrOut ? CGAffineTransformMakeScale(0.9, 0.9) : CGAffineTransformMakeScale(1.1, 1.1);
                         self.itemGridView.alpha = 0.5;
                     }
                     completion:^(BOOL completed) {
                         [self.itemGridView reloadData];
                         [UIView animateWithDuration:part2Duration
                                               delay:0
                                             options:UIViewAnimationCurveEaseOut
                                          animations:^{
                                              self.itemGridView.transform = CGAffineTransformIdentity;
                                              self.itemGridView.alpha = 1.0;
                                          }
                                          completion:^(BOOL completed) {
                                              
                                          }
                          ];
                     }];

}

#pragma mark - Button Action Methods

-(IBAction)addItemButtonPressed:(id)sender
{
    if (!self.person) {
        NSLog(@"Tried to add a capture item to a nil WSCDPerson...ignoring.");
        return;
    }
    
    //leave edit mode if we're in it.
    [self setEditing:NO];
    
    WSCDItem *newCaptureItem = [NSEntityDescription insertNewObjectForEntityForName:@"WSCDItem" inManagedObjectContext:self.person.managedObjectContext];

    //insert this item at the beginning of the list.
    newCaptureItem.index = [NSNumber numberWithInt:0]; 
    
    //Update the indices of everything in the existing array to make room for the new item.
    for (int i = 0; i < [orderedItems count]; i++) {
        WSCDItem *tempItem = [orderedItems objectAtIndex:i];
        tempItem.index = [NSNumber numberWithInt:[tempItem.index intValue] + 1];
    }
    
    [self.person addItemsObject:newCaptureItem];
    
    //update the local (sorted) data
    [self updateData];

    //Save the context
    [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];    
    
    //animate a reload of the data
    [self reloadItemGridAnimated:NO];
 }

-(IBAction)duplicateRowButtonPressed:(id)sender
{
    [delegate didRequestDuplicatePerson:self.person];
}

-(IBAction)editButtonPressed:(id)sender
{
    [self setEditing:!self.editing];

}

-(IBAction)deleteButtonPressed:(id)sender
{
    deletePersonSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete this person"
                                                    otherButtonTitles:nil];
    [deletePersonSheet showFromRect:self.deleteButton.frame inView:self animated:YES];
}

#pragma mark - Action Sheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == deletePersonSheet && buttonIndex != actionSheet.cancelButtonIndex) {
        //request a deletion
        [delegate didRequestDeletePerson:self.person];
    }
    else if (actionSheet == deleteItemSheet && buttonIndex != actionSheet.cancelButtonIndex && deletableItem >= 0) {
        //Having confirmed the deletion, perform it.
        [self performItemDeletionAtIndex:deletableItem];
        //reset the deletable item index.
        deletableItem = -1;
    }

}

#pragma mark -
#pragma mark GridView Data Source
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if (orderedItems) {
        return [orderedItems count];
    }
    else return 0;
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(kItemCellSize, kItemCellSize);
}


- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    WSItemGridCell *cell =(WSItemGridCell*) [gridView dequeueReusableCell];

    if(!cell) {
        cell = [[WSItemGridCell alloc] init];
        CGSize theSize = [self sizeForItemsInGMGridView:gridView];
        cell.bounds = CGRectMake(0, 0, theSize.width, theSize.height);
    }
    cell.item = [orderedItems objectAtIndex:index];
    cell.tempLabel.text = [NSString stringWithFormat:@"Grid Index %d\nInternal Index %d",index, [cell.item.index intValue]];
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    deleteItemSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Item"
                                                    otherButtonTitles:nil];

    deletableItem = index; //mark this cell for deletion if the user confirms the action.
    
    GMGridViewCell *activeCell;           

    // Might return nil if cell not loaded for the specific index
    if ((activeCell = [self.itemGridView cellForItemAtIndex:index])) { 
        [deleteItemSheet showFromRect:activeCell.bounds inView:activeCell animated:YES];
    }
    else {
        //default to showing this from the entire view.
        [deleteItemSheet showFromRect:self.bounds inView:self animated:YES];
    }
}


-(void) performItemDeletionAtIndex:(int) index
{
    //if we have a valid item, delete it and reload the grid.
    WSCDItem *foundItem = [orderedItems objectAtIndex:index];
    if (foundItem) {
        [self.person removeItemsObject:foundItem];
        //rebuild the ordered collection.
        [self updateData]; 
        //update the item indices within the now-updated ordered collection
        for (int i = 0; i < [orderedItems count]; i++) {
            WSCDItem *tempItem = [orderedItems objectAtIndex:i];
            tempItem.index = [NSNumber numberWithInt:i];
        }
                
        //animate a reload of the data
        [self reloadItemGridAnimated:YES];

        //Save the context
        [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];

        //FIXME: make sure we remain in edit mode. This shouldn't be required.
        //Figure out why we bounce back out of edit mode after a delete.
        self.editing = YES;
    }
    else
    {
        NSLog(@"Tried to remove a nonexistent item at index %d",index);
    }
}

#pragma mark - GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"Did tap at index %d", position);
    
    WSItemGridCell *activeCell = (WSItemGridCell*)[gridView cellForItemAtIndex:position];
                                  
    //If we found a valid item, launch the capture popover from it.
    if (activeCell) {
        WSCaptureController *cap = [[WSCaptureController alloc] initWithNibName:@"WSCaptureController" bundle:nil];
        
        if (popoverController) {
            popoverController.contentViewController = cap;
        }
        else {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:cap];
        }
        
        popoverController.popoverContentSize = cap.view.bounds.size;
        [popoverController presentPopoverFromRect:[self.superview convertRect:activeCell.bounds fromView:activeCell] 
                                           inView:self.superview 
                         permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) 
                                         animated:YES];
    }
}



#pragma mark - GMGridViewSortingDelegate

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    //disable the gesture recognizers on the main table view.
    ((UITableView*)self.superview).scrollEnabled = NO;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^{
                         //cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     } 
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    ((UITableView*)self.superview).scrollEnabled = YES;
    [self.itemGridView reloadData];
    [UIView animateWithDuration:0.3 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^{  
                         //cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];

}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{

    //Based on the sample code, looks like the requested behavior here is:
    // - Remove the old item & reindex
    // - Insert the item into the reindexed array at the requested index position.

    WSCDItem *tempItem = [orderedItems objectAtIndex:oldIndex];
    [orderedItems removeObjectAtIndex:oldIndex];
    [orderedItems insertObject:tempItem atIndex:newIndex];
    
    //update the item indices within the now-updated ordered collection
    for (int i = 0; i < [orderedItems count]; i++) {
        WSCDItem *tempItem = [orderedItems objectAtIndex:i];
        tempItem.index = [NSNumber numberWithInt:i];
    }
    
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [orderedItems exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    //update the item indices within the now-updated ordered collection
    for (int i = 0; i < [orderedItems count]; i++) {
        WSCDItem *tempItem = [orderedItems objectAtIndex:i];
        tempItem.index = [NSNumber numberWithInt:i];
    }

}

#pragma mark - DraggableGridViewTransformingDelegate

- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return CGSizeMake(700, 530);
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    UIView *fullView = [[UIView alloc] init];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
//    fullView.center = [[UIApplication sharedApplication] win
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %d", index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    label.font = [UIFont boldSystemFontOfSize:20];
    
    [fullView addSubview:label];
    
    
    return fullView;
}

- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^{
                         //cell.contentView.backgroundColor = [UIColor blueColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     } 
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^{
                         //cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     } 
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
{
    
}




@end
