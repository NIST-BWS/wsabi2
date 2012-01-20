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
@synthesize cellGridView;
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
        
        //configure UI elements
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-highlighted"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateDisabled];
        
        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-highlighted"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"glossyButton-black-disabled"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateDisabled];
        
        //new rows that start selected need to have the active controls' highlights turned off.
        self.duplicateRowButton.highlighted = !self.selected;
        self.addButton.highlighted = !self.selected;
        self.editButton.highlighted = !self.selected;
        self.deleteButton.highlighted = !self.selected;
        
        //update the local data information from Core Data
        [self updateData];
        
        //configure and reload the grid view
        self.cellGridView.backgroundColor = [UIColor clearColor];
        self.cellGridView.cellSize = CGSizeMake(100.0, 100.0);
        self.cellGridView.cellPadding = CGSizeMake(34.0, 17.0);
        [self.cellGridView reloadData];

        initialLayoutComplete = YES;
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
            self.cellGridView.frame = CGRectMake(self.cellGridView.frame.origin.x, 
                                                 128, 
                                                 self.cellGridView.frame.size.width,
                                                 self.bounds.size.height - 128 - 30); //subtract extra space from the height because of the New Person button visible at the bottom.
        }];
    }
    else {
        //If anything is selected in the grid, deselect it.
        if ([self.cellGridView indexPathForSelectedCell]) {
            [self.cellGridView deselectItemsAtIndexPaths:[NSArray arrayWithObject:[self.cellGridView indexPathForSelectedCell]] animated:YES];
        }
        [UIView animateWithDuration:kTableViewContentsAnimationDuration animations:^{
                            self.customSelectedBackgroundView.alpha = 0.0;
                            self.duplicateRowButton.alpha = 0.0;
                            self.addButton.alpha = 0.0;
                            self.editButton.alpha = 0.0;
                            self.deleteButton.alpha = 0.0;
                            self.cellGridView.frame = CGRectMake(self.cellGridView.frame.origin.x, 
                                                 12, 
                                                 self.cellGridView.frame.size.width,
                                                 self.bounds.size.height - 24); //Leave a 12-pixel border above and below
                        } 
//                         completion:^(BOOL completed) {
//                            self.customSelectedBackgroundView.hidden = YES;
//                        }
         
        ];
    }
    self.cellGridView.userInteractionEnabled = selected;
}

-(void) setPerson:(WSCDPerson *)newPerson
{
    person = newPerson;
    [self updateData];
}

-(void) updateData
{

    NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"timeStampCreated" ascending:NO]];
   
    
    //get a sorted array of items
    orderedItems = [self.person.items sortedArrayUsingDescriptors:sortDescriptors];
    
}

#pragma mark - Button Action Methods

-(IBAction)addItemButtonPressed:(id)sender
{
    if (!self.person) {
        NSLog(@"Tried to add a capture item to a nil WSCDPerson...ignoring.");
        return;
    }
    
    //Add the new item, deselecting anything else in the list.
    if ([self.cellGridView indexPathForSelectedCell]) {
        [self.cellGridView deselectItemsAtIndexPaths:[NSArray arrayWithObject:[self.cellGridView indexPathForSelectedCell]] animated:YES];
    }

    WSCDItem *newCaptureItem = [NSEntityDescription insertNewObjectForEntityForName:@"WSCDItem" inManagedObjectContext:self.person.managedObjectContext];
    
    [self.person addItemsObject:newCaptureItem];
    
    //Save the context
    [(WSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    //update the local (sorted) data
    [self updateData];
    
    [self.cellGridView insertItemsAtIndexPaths:[NSArray arrayWithObject:[KKIndexPath indexPathForIndex:0 inSection:0]] withAnimation:KKGridViewAnimationExplode];
}

-(IBAction)duplicateRowButtonPressed:(id)sender
{
    [delegate didRequestDuplicatePerson:self.person];
}

-(IBAction)editButtonPressed:(id)sender
{
    self.editing = !self.editing;
    ((UIButton*)sender).selected = !((UIButton*)sender).selected;
    [self.cellGridView reloadData];
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
}

#pragma mark -
#pragma mark GridView Data Source
- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    if (orderedItems) {
        return [orderedItems count];
    }
    else return 0;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
    WSItemGridCell *cell = [WSItemGridCell cellForGridView:gridView];
    
    return cell;
}

@end
