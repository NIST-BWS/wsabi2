// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSDDLog.h"
#import "UIImage+NBCLExtras.h"

#import "BWSPersonTableViewCell.h"

#import "BWSAppDelegate.h"

#define GRID_CELL_OFFSET 1000

@implementation BWSPersonTableViewCell
@synthesize deletePersonOverlayViewCancelButton;
@synthesize deletePersonOverlayViewDeleteButton;
@synthesize captureController;
@synthesize selectedIndex;
@synthesize person;
@synthesize itemGridView;
@synthesize biographicalDataButton, biographicalDataInactiveLabel, timestampLabel, timestampInactiveLabel;
@synthesize editButton, addButton, deleteButton, duplicateRowButton;
@synthesize shadowUpView, shadowDownView, customSelectedBackgroundView;
@synthesize deletePersonOverlayView, separatorView;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self != nil) {
        [self startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        
        [[self biographicalDataButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[self editButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[self deleteButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[self addButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        [[self duplicateRowButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    }
    
    return (self);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) layoutGrid {
    //if the grid has fewer cells than would make a full row, we need to resize the grid.
    //FIXME: This is because turning off the "centerGrid" property in GMGridView introduces a
    //LOT of graphical problems.
    float gridWidth = self.contentView.bounds.size.width - 92 - kItemCellSpacing;
    float leftOffset = 92;
    if (leftOffset + kItemCellSpacing + ((kItemCellSize + kItemCellSpacing) * [orderedItems count]) 
        < self.contentView.bounds.size.width) {
        gridWidth = 4*kItemCellSpacing + ([orderedItems count] * (kItemCellSize + kItemCellSpacing));
    }
    if (self.selected) {
        self.itemGridView.frame = CGRectMake(92,
                                             96,
                                             gridWidth,
                                             self.contentView.bounds.size.height - 96 - 30 - kItemCellSpacing);
    }
    else {
        self.itemGridView.frame = CGRectMake(92,
                                             24,
                                             gridWidth,
                                             self.contentView.bounds.size.height - 24 - kItemCellSpacing);
        
    }
    

}

-(void) layoutSubviews {
    [super layoutSubviews];

    if (!initialLayoutComplete) {
        
        deletableItem = -1;
        selectedIndex = -1;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM d, yyyy h:mm a";
        
        //configure UI elements
        normalBGColor = [UIColor clearColor];
        selectedBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-Linen"]];
        
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueButtonPressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:16] forState:UIControlStateNormal];
        [self.duplicateRowButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueButton"] stretchableImageWithLeftCapWidth:6 topCapHeight:16] forState:UIControlStateHighlighted];
        
        UIImage *silverButton = [[UIImage imageNamed:@"kb-extended-candidates-segmented-control-button"] stretchableImageWithLeftCapWidth:5 topCapHeight:7];
        UIImage *silverButtonPressed = [[UIImage imageNamed:@"kb-extended-candidates-segmented-control-button-selected"] stretchableImageWithLeftCapWidth:5 topCapHeight:7];
        [self.biographicalDataButton setBackgroundImage:silverButton forState:UIControlStateNormal];
        [self.deleteButton setBackgroundImage:silverButton forState:UIControlStateNormal];
        [self.addButton setBackgroundImage:silverButton forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:silverButton forState:UIControlStateNormal];
        
        [self.biographicalDataButton setBackgroundImage:silverButtonPressed forState:UIControlStateHighlighted];
        [self.deleteButton setBackgroundImage:silverButtonPressed forState:UIControlStateHighlighted];
        [self.addButton setBackgroundImage:silverButtonPressed forState:UIControlStateHighlighted];
        [self.editButton setBackgroundImage:silverButtonPressed forState:UIControlStateHighlighted];

        [self.editButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarDoneButton"] stretchableImageWithLeftCapWidth:6 topCapHeight:16] forState:UIControlStateSelected];
        
        self.shadowUpView.image = [[UIImage imageNamed:@"cell-drop-shadow-up"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        self.shadowDownView.image = [[UIImage imageNamed:@"cell-drop-shadow-down"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        
        //new rows that start selected need to have the active controls' highlights turned off.
        self.duplicateRowButton.highlighted = NO;
        self.biographicalDataButton.highlighted = NO;
        self.addButton.highlighted = NO;
        self.editButton.highlighted = NO;
        self.deleteButton.highlighted = NO;
        
        //update the local data information from Core Data
        [self updateData];
        
        //configure and reload the grid view
        //NOTE: The grid view has to be initialized here, because at least for the moment, GMGridView doesn't have an initWithCoder implementation.
        //self.itemGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
        self.itemGridView = [[GMGridView alloc] initWithFrame:CGRectMake(92, 
                                                                         2*kItemCellSpacing,
                                                                         self.contentView.bounds.size.width - 92 - kItemCellSpacing,
                                                                         self.contentView.bounds.size.height - 3*kItemCellSpacing)];
	    [self.itemGridView setCenterGrid:NO];
        
        self.itemGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.itemGridView.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]; 
        self.itemGridView.style = GMGridViewStylePush;
        self.itemGridView.itemSpacing = kItemCellSpacing;
        self.itemGridView.minEdgeInsets = UIEdgeInsetsMake(kItemCellSpacing, kItemCellSpacing, kItemCellSpacing, kItemCellSpacing);
        
        // set extra space buffers for cell dragging.
        self.itemGridView.dragBufferTop = 84;
        self.itemGridView.dragBufferLeft = 25;
        self.itemGridView.dragBufferRight = 12;
        self.itemGridView.dragBufferBottom = 22;
        
        self.itemGridView.actionDelegate = self;
        self.itemGridView.sortingDelegate = self;
        //self.itemGridView.transformDelegate = self;
        self.itemGridView.dataSource = self;
        self.itemGridView.userInteractionEnabled = NO; //start with this disabled unless we actively set this cell to selected.
        
        [self.contentView insertSubview:self.itemGridView aboveSubview:self.duplicateRowButton]; //make sure drag & drop looks right by placing the grid above everything else.
        
        [[self itemGridView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeLongPress];
        
        //add notification listeners
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDownloadPosted:) 
                                                     name:kSensorLinkDownloadPosted
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeItem:)
                                                     name:kChangedWSCDItemNotification
                                                   object:nil];

        initialLayoutComplete = YES;
    }
    
    //if this isn't the selected cell, make sure it's not in edit mode.
    if (!self.selected) {
        self.editing = NO;
        
        // Handle case where user taps another row before canceling a deletion
        [UIView animateWithDuration:kTableViewContentsAnimationDuration
                         animations:^() {[[self deletePersonOverlayView] setAlpha:0.0];}
                         completion:^(BOOL finished) {[[self deletePersonOverlayView] removeFromSuperview];}];
    }
    
    //Make sure the labels are right.
    if (self.person.firstName || self.person.middleName || self.person.lastName) {
        self.biographicalDataInactiveLabel.text = [self biographicalShortName];
    }
    else {
        self.biographicalDataInactiveLabel.text = nil;
    }
    self.timestampLabel.text = [NSString stringWithFormat:@"Created: %@",[dateFormatter stringFromDate:self.person.timeStampCreated]];
    self.timestampInactiveLabel.text = [NSString stringWithFormat:@"Created: %@",[dateFormatter stringFromDate:self.person.timeStampCreated]];
    
    [self.biographicalDataButton setTitle:[self biographicalShortName] forState:UIControlStateNormal];

    //Finally, make sure our alpha is set correctly based on the selectedness of this row.
    self.itemGridView.alpha = (self.selected && (self.deletePersonOverlayView.hidden == YES)) ? 1.0 : 0.3;
    
    [self layoutGrid];
    
    //make sure the separator stays visible.
    [self bringSubviewToFront:self.separatorView];
}

-(void) dealloc
{
    //we need to remove observers here.
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [self stopLoggingBWSInterfaceEvents];
    [[self itemGridView] stopLoggingBWSInterfaceEvents];
    
    [[self biographicalDataButton] stopLoggingBWSInterfaceEvents];
    [[self editButton] stopLoggingBWSInterfaceEvents];
    [[self deleteButton] stopLoggingBWSInterfaceEvents];
    [[self addButton] stopLoggingBWSInterfaceEvents];
    [[self duplicateRowButton] stopLoggingBWSInterfaceEvents];
}

- (void)setAppearDisabled:(BOOL)yesOrNo animated:(BOOL)animated
{
    static const CGFloat kDisabledAlpha = 0.3;
    CGFloat alphaValue = (yesOrNo == YES ? kDisabledAlpha : 1.0);
 
    void (^animationBlock) (void) = ^(void) {
        [[self itemGridView] setUserInteractionEnabled:!yesOrNo];
        [[self itemGridView] setAlpha:alphaValue];
        
        [[self addButton] setUserInteractionEnabled:!yesOrNo];
        [[self addButton] setAlpha:alphaValue];
        
        [[self biographicalDataButton] setUserInteractionEnabled:!yesOrNo];
        [[self biographicalDataButton] setAlpha:alphaValue];
        
        [[self editButton] setUserInteractionEnabled:!yesOrNo];
        [[self editButton] setAlpha:alphaValue];
        
        [[self deleteButton] setUserInteractionEnabled:!yesOrNo];
        [[self deleteButton] setAlpha:alphaValue];
        
        [[self timestampLabel] setAlpha:alphaValue];
    };
    
    if (animated)
        [UIView animateWithDuration:kTableViewContentsAnimationDuration animations:animationBlock];
    else
        animationBlock();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if ([super isSelected] == selected)
        return;
    
    [super setSelected:selected animated:animated];
    
    void (^preSelectionAnimation)(void) = ^(void) {
        self.separatorView.alpha = (selected ? 0.0 : 1.0);
        self.duplicateRowButton.alpha = (selected ? 1.0 : 0.0);
        self.timestampInactiveLabel.alpha = (selected ? 0.0 : 1.0);
    };
    
    void (^toggleSelection)(void) = ^(void) {
        self.shadowUpView.alpha = (selected ? 1.0 : 0.0);
        self.shadowDownView.alpha = (selected ? 1.0 : 0.0);
        self.timestampLabel.alpha = (selected ? 1.0 : 0.0);
        self.biographicalDataButton.alpha = (selected ? 1.0 : 0.0);
        self.biographicalDataInactiveLabel.alpha = (selected ? 0.0 : 1.0);
        self.addButton.alpha = (selected ? 1.0 : 0.0);
        self.editButton.alpha = (selected ? 1.0 : 0.0);
        self.deleteButton.alpha = (selected ? 1.0 : 0.0);
        self.itemGridView.alpha = (selected ? 1.0 : 0.3);
        self.customSelectedBackgroundView.backgroundColor = (selected ? selectedBGColor : normalBGColor);
        self.deletePersonOverlayView.alpha = (selected ? 0.0 : 1.0);
            
        if (selected) {
            self.contentView.alpha = 1.0;
            self.deletePersonOverlayView.hidden = YES;
        }
    };
    
    void (^toggleSelectionCompletion)(BOOL finished) = ^(BOOL finished) {
        [self layoutGrid];
        self.itemGridView.userInteractionEnabled = selected;
    };
    
    
    preSelectionAnimation();
    if (animated)
        [UIView animateWithDuration:kTableViewContentsAnimationDuration
                         animations:toggleSelection
                         completion:toggleSelectionCompletion];
    else {
        toggleSelection();
        toggleSelectionCompletion(YES);
    }

    
    if (selected) {
        //Set up sensor links for each item in this person's record.
        //(It's likely that these links will come back initialized.)
        for (BWSCDItem *item in self.person.items) {
            BWSDeviceLink *link = [[BWSDeviceLinkManager defaultManager] deviceForUri:item.deviceConfig.uri];
            DDLogBWSDevice(@"Created/grabbed sensor link %@",[link description]);
        }
        [self setAppearDisabled:NO animated:NO];
    } else {
        [self selectItem:nil];
        selectedIndex = -1;
    }
}

-(void) setPerson:(BWSCDPerson *)newPerson
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
    
    //notify the delegate
    [delegate didChangeEditingStatusForPerson:self.person newStatus:newEditingStatus];
}

-(NSString*)biographicalShortName
{
    NSString *placeholder = @"Tap to set name";
    BOOL foundSomething = NO;
    NSMutableString *result = [[NSMutableString alloc] init];
    
    if (!self.person) {
        return placeholder; //nothing to add.
    }
    
    if (self.person.firstName && self.person.firstName.length > 0) {
        [result appendFormat:@"%@ ", self.person.firstName];
        foundSomething = YES;
    }
    if (self.person.middleName && self.person.middleName.length > 0) {
        [result appendFormat:@"%@ ", self.person.middleName];
        foundSomething = YES;
    }
    if (self.person.lastName && self.person.lastName.length > 0) {
        [result appendFormat:@"%@", self.person.lastName];
        foundSomething = YES;
    }
    
    if (result.length == 0 && self.person.otherName.length > 0) {
        [result appendFormat:@"%@", self.person.otherName];
        foundSomething = YES;
    }

    if (foundSomething) {
        return result;
    }
    else
        return placeholder; 
}

-(void) updateData
{

    NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES]];
   
    
    //get a sorted array of items
    orderedItems = [[self.person.items sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
}

-(void) removeBackingStoreForItem:(id)userInfo
{
    BWSCDItem *foundItem = [orderedItems objectAtIndex:deletableItem];
	if (foundItem == nil) {
        DDLogBWSVerbose(@"Tried to remove a nonexistent item at index %d", deletableItem);
        return;
    }
    
    //rebuild the ordered collection.
    [self.person removeItemsObject:foundItem];
    [[(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] deleteObject:foundItem];
    [self updateData]; 
    
    //update the item indices within the now-updated ordered collection
    for (NSUInteger i = 0; i < [orderedItems count]; i++) {
        BWSCDItem *tempItem = [orderedItems objectAtIndex:i];
        tempItem.index = [NSNumber numberWithInt:i];
    }
    
    //Save the context
    [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    deletableItem = -1;
}

-(void) removeItem:(int)itemIndex animated:(BOOL)animated
{
    [self.itemGridView removeObjectAtIndex:deletableItem withAnimation:animated ? 
     GMGridViewItemAnimationFade | GMGridViewItemAnimationScroll :
     GMGridViewItemAnimationNone];
    
    // GMGridView nests animations within the completion blocks instead
    // of the animation block.  Because of this, we return to this method
    // before the animations have ended and then change the data model,
    // which in turn changes the nested animation.  To fix, wait the duration
    // of the entirety of the GMGridView animation before changing the
    // backing store.
    if (animated)
        [NSTimer scheduledTimerWithTimeInterval:0.6 // kDefaultAnimationDuration * 2
                                         target:self
                                       selector:@selector(removeBackingStoreForItem:) 
                                       userInfo:nil 
                                        repeats:NO];
    else
        [self removeBackingStoreForItem:nil];
    
    //FIXME: make sure we remain in edit mode. This shouldn't be required.
    //Figure out why we bounce back out of edit mode after a delete.
    self.editing = YES;
}

- (void)dismissBiographicalPopover
{
    if (biographicalPopover != nil)
        [biographicalPopover dismissPopoverAnimated:NO];
}

#pragma mark - Button Action Methods
-(IBAction)biographicalDataButtonPressed:(id)sender
{
    
    //cancel edit mode if we're in it.
    [self setEditing:NO];
    
    //hide any capture controllers that are visible
    if (capturePopover) {
        [capturePopover dismissPopoverAnimated:YES];
    }
    
    //We're going to put this in a secondary popover controller.
    BWSBiographicalDataController *cap = [[BWSBiographicalDataController alloc] initWithNibName:@"BWSBiographicalDataController" bundle:nil];
    cap.person = self.person;
    cap.delegate = self;
    
    UINavigationController *tempNav = [[UINavigationController alloc] initWithRootViewController:cap];
    tempNav.view.accessibilityLabel = @"Biographical Data";

    if (!biographicalPopover) {
        biographicalPopover = [[UIPopoverController alloc] initWithContentViewController:tempNav];
    }
    else {
        biographicalPopover.contentViewController = tempNav;
    }

    biographicalPopover.popoverBackgroundViewClass = [GIKPopoverBackgroundView class];
    biographicalPopover.contentViewController = tempNav;
    biographicalPopover.delegate = self;
    cap.popoverController = biographicalPopover;
     
    biographicalPopover.popoverContentSize = CGSizeMake(cap.view.bounds.size.width, cap.view.bounds.size.height + 36); //leave room for the nav bar
        
    [biographicalPopover presentPopoverFromRect:[self convertRect:self.biographicalDataButton.bounds fromView:self.biographicalDataButton] 
                                       inView:self 
                     permittedArrowDirections:(UIPopoverArrowDirectionLeft) 
                                     animated:YES];
    _biographicalDataVisible = YES;
    [self.biographicalDataButton logPopoverControllerPresented:biographicalPopover];
}

-(IBAction)addItemButtonPressed:(id)sender
{
    if (!self.person) {
        DDLogBWSVerbose(@"%@", @"Tried to add a capture item to a nil WSCDPerson...ignoring.");
        return;
    }
    
    //Create a temporary item
    NSEntityDescription *entity = [NSEntityDescription entityForName:kBWSEntityItem inManagedObjectContext:self.person.managedObjectContext];
    BWSCDItem *newCaptureItem = (BWSCDItem*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

    //insert this item at the beginning of the list.
    newCaptureItem.index = [NSNumber numberWithInt:[self.person.items count]]; 
    newCaptureItem.submodality = [BWSModalityMap stringForCaptureType:kCaptureTypeNotSet];

//    //Update the indices of everything in the existing array to make room for the new item.
//    for (int i = 0; i < [orderedItems count]; i++) {
//        WSCDItem *tempItem = [orderedItems objectAtIndex:i];
//        tempItem.index = [NSNumber numberWithInt:[tempItem.index intValue] + 1];
//    }
//    
    //leave edit mode if we're in it.
    [self setEditing:NO];

    //dismiss the capture popover
    if ([capturePopover isPopoverVisible] == YES) {
        [capturePopover dismissPopoverAnimated:YES];
        [(UIView *)sender logPopoverControllerDismissed:capturePopover];
    }

    ((UITableView*)self.superview).scrollEnabled = YES;

    //launch the sensor walkthrough for this item.
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:newCaptureItem forKey:kDictKeyTargetItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];

 }

-(IBAction)duplicateRowButtonPressed:(id)sender
{
    //make sure we're not editing anything, then notify the delegate that
    //we want to duplicate this row.
    [self setEditing:NO];
    ((UITableView*)self.superview).scrollEnabled = YES;
    [delegate didRequestDuplicatePerson:self.person];
    
}

-(IBAction)editButtonPressed:(id)sender
{
    [self setEditing:![[self editButton] isSelected]];

    // Make and pressed image match the new state of the button
    if ([[self editButton] isSelected]) {
        [[self editButton] setTitle:NSLocalizedString(@"Done", nil) forState:(UIControlStateHighlighted|UIControlStateSelected)];
        UIImage *doneButtonPressed = [[UIImage imageNamed:@"UINavigationBarDoneButtonPressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:16];
        [[self editButton] setBackgroundImage:doneButtonPressed forState:UIControlStateSelected|UIControlStateHighlighted];
    } else {
        [[self editButton] setTitle:NSLocalizedString(@"Edit", nil) forState:(UIControlStateHighlighted|UIControlStateSelected)];
        UIImage *silverButtonPressed = [[UIImage imageNamed:@"kb-extended-candidates-segmented-control-button-selected"] stretchableImageWithLeftCapWidth:5 topCapHeight:7];
        [[self editButton] setBackgroundImage:silverButtonPressed forState:UIControlStateSelected|UIControlStateHighlighted];
    }
}

-(IBAction)deleteButtonPressed:(id)sender
{
    deletePersonSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete this person"
                                                    otherButtonTitles:nil];
    
    [deletePersonSheet showFromRect:self.deleteButton.frame inView:self animated:YES];
    
    [(UIView *)sender logActionSheetPresented:deletePersonSheet];
}

- (IBAction)deletePersonOverlayDeletePersonButtonPressed:(id)sender
{
    // Delete the person while the overlay cell is still visible
    [delegate didRequestDeletePerson:self.person];
    
    [UIView animateWithDuration:kTableViewContentsAnimationDuration
                     animations:^(void) {
                         [self setAppearDisabled:NO animated:NO];
                     }
                     completion:^(BOOL finished) {
                         [[self deletePersonOverlayView] removeFromSuperview];
                     }
     ];
}

- (IBAction)deletePersonOverlayCancelButtonPressed:(id)sender
{
   [UIView animateWithDuration:kTableViewContentsAnimationDuration
                    animations:^(void) {
                        [[self deletePersonOverlayView] setAlpha:0.0];
                        [self setAppearDisabled:NO animated:NO];
                    }
                    completion:^(BOOL finished) {
                        [[self deletePersonOverlayView] removeFromSuperview];
                    }
    ];
}

#pragma mark - Action Sheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == deletePersonSheet && buttonIndex != actionSheet.cancelButtonIndex) {
        // Size the overlay to fit within the cell
        [[self deletePersonOverlayView] setFrame:self.customSelectedBackgroundView.frame];
        [[self contentView] addSubview:self.deletePersonOverlayView];
        // Keep duplicate row button on top of overlay
        [self.contentView bringSubviewToFront:self.duplicateRowButton];
        
        // Customize the button appearance
        UIEdgeInsets insets = UIEdgeInsetsMake(24, 12, 24, 12);
        [[self deletePersonOverlayViewDeleteButton] setBackgroundImage:[[UIImage imageNamed:@"UIAlertSheetDefaultDestroyButton"]
                                                                        resizableImageWithCapInsets:insets]
                                                              forState:UIControlStateNormal];
        [[self deletePersonOverlayViewDeleteButton] setBackgroundImage:[[UIImage imageNamed:@"UIAlertSheetDefaultDestroyButtonPressed"]
                                                                        resizableImageWithCapInsets:insets]
                                                              forState:UIControlStateHighlighted];
        [[self deletePersonOverlayViewCancelButton] setBackgroundImage:[[UIImage imageNamed:@"UIAlertSheetDefaultCancelButton"]
                                                                        resizableImageWithCapInsets:insets]
                                                              forState:UIControlStateNormal];
        
        // The NIB shows this as interaction enabled, but certainly isn't...
        [[self deletePersonOverlayView] setUserInteractionEnabled:YES];
        
        [UIView animateWithDuration:kTableViewContentsAnimationDuration 
                         animations:^(void) {
                             [self setAppearDisabled:YES animated:NO];
                             
                             // Send in the confirmation overlay
                             [[self deletePersonOverlayView] setHidden:NO];
                             [[self deletePersonOverlayView] setAlpha:1.0];
                         }
         ];
    }
    else if (actionSheet == deleteItemSheet && buttonIndex != actionSheet.cancelButtonIndex && deletableItem >= 0) {
        [self removeItem:deletableItem animated:YES];
    }
    
    //Log the action sheet's closing
    [self logActionSheetDismissed:actionSheet viaButtonAtIndex:buttonIndex];
}

#pragma mark - Biographical Data delegate
-(void) didUpdateDisplayName
{
    [self.biographicalDataButton setTitle:[self biographicalShortName] forState:UIControlStateNormal];
}

#pragma mark - Notification handlers
-(void) didChangeItem:(NSNotification*)notification
{
    BWSCDItem *item = [notification.userInfo objectForKey:kDictKeyTargetItem];

    if (![self.person.items containsObject:item]) {
        return; //nothing to do if we don't have this item.
    }
    
    //NOTE: it would be better just to reload the single cell, but for some reason,
    //even though all variables seem to be in place, reloading the single cell
    //results in the updated cell being deselected even when it ought to be selected.
    //Calling reloadData behaves as expected, and there doesn't seem to be a noticeable
    //performance hit.
    
//    [self.itemGridView reloadObjectAtIndex:[orderedItems indexOfObject:item] animated:YES];
    [self.itemGridView reloadData];
}

-(void) handleDownloadPosted:(NSNotification*)notification
{
    //Do this in the most simpleminded way possible
    NSMutableDictionary *info = (NSMutableDictionary*)notification.userInfo;
    
    BWSCDItem *targetItem = (BWSCDItem*) [self.person.managedObjectContext objectWithID: [self.person.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[info objectForKey:kDictKeyDeviceID]]];
    
    //If this item is ours, update it.
    NSData *imageData = [info objectForKey:@"data"]; //may be nil
    
    if (imageData && [orderedItems containsObject:targetItem]) {
        targetItem.data = imageData;
		targetItem.thumbnail = UIImagePNGRepresentation([UIImage scaleImage:[UIImage imageWithData:imageData] toSize:CGSizeMake(2 * kItemCellSize, 2 * kItemCellSize) withCornerRadius:2.0 * kItemCellCornerRadius]);
//        targetItem.thumbnail = UIImageJPEGRepresentation([UIImage scaleImage:[UIImage imageWithData:imageData] toSize:CGSizeMake(2 * kItemCellSize, 2 * kItemCellSize) withCornerRadius:2.0 *kItemCellCornerRadius], 0.5 );
//        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
//        
//        [UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.5) writeToFile:jpgPath atomically:YES];
        
        //[targetItem.thumbnail writeToFile:jpgPath atomically:YES];
        //FIXME: This needs to handle metadata coming back from the sensor!
    }
    
    [self updateData];
    [self.itemGridView reloadData];
    
    //save the context
    [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
}

#pragma mark - Capture Controller delegate
-(void) didRequestCapturePreviousItem:(BWSCDItem*)currentItem
{
    //find this item, then start capture on the previous item instead.
    int index = [orderedItems indexOfObject:currentItem];
    
    if (index != NSNotFound && index > 0) {
        [self showCapturePopoverAtIndex:index-1];
    }
}

-(void) didRequestCaptureNextItem:(BWSCDItem*)currentItem
{
    //find this item, then start capture on the next item instead.
    int index = [orderedItems indexOfObject:currentItem];
    
    if (index != NSNotFound && index < ([orderedItems count]-1)) {
        [self showCapturePopoverAtIndex:index+1];
    }

}

-(void) selectItem:(BWSItemGridCell*)cellToSelect
{
    // We're deselecting everything
    if(cellToSelect == nil)
        selectedIndex = -1;
    
    for (UIView *v in self.itemGridView.subviews) {
        if ([v isKindOfClass:[BWSItemGridCell class]]) {
            BWSItemGridCell *cell = ((BWSItemGridCell*)v);
            if (cell == cellToSelect) {
                cell.selected = YES;
                selectedIndex = [orderedItems indexOfObject:cell.item];
            }
            else {
                cell.selected = NO;
            }
        }
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

- (CGSize) GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(kItemCellSize, kItemCellSize+kItemCellSizeVerticalAddition);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    static NSString *CellIdentifier = @"gridCell";
    
    BWSItemGridCell *cell =(BWSItemGridCell*) [gridView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(!cell) {
        cell = [[BWSItemGridCell alloc] init];
        cell.reuseIdentifier = CellIdentifier;
        CGSize theSize = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:UIInterfaceOrientationPortrait];
        cell.bounds = CGRectMake(0, 0, theSize.width, theSize.height);
    }

    cell.item = [orderedItems objectAtIndex:index];
    cell.active = self.selected;
    cell.selected = (index == self.selectedIndex);
    //cell.tempLabel.text = [NSString stringWithFormat:@"Grid Index %d\nInternal Index %d",index, [cell.item.index intValue]];
    cell.tag = GRID_CELL_OFFSET + index;
    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES;
}


//-(void) performItemDeletionAtIndex:(int) index
//{
//}

-(void) showCapturePopoverAtIndex:(int) index
{
    DDLogBWSVerbose(@"Asking to show popover for item at index %d",index);
    ((UITableView*)self.superview).scrollEnabled = NO;
    
    // Force a redraw of the popover so that orientation is not reused
    if ([capturePopover isPopoverVisible]) {
        [self logPopoverControllerDismissed:capturePopover];
        [capturePopover dismissPopoverAnimated:NO];
    }
    
    BWSItemGridCell *activeCell = (BWSItemGridCell*)[self.itemGridView cellForItemAtIndex:index];
           
    //If we found a valid item, launch the capture popover from it.
    if (activeCell) {

        //Move the highlight to this new cell
        [self selectItem:activeCell];
        
        CGRect showPopoverFromRect = [activeCell frame];
        UIPopoverArrowDirection direction = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) : (UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight);

        //Find the item we want to edit.
        BWSCDItem *targetItem = [orderedItems objectAtIndex:index];

        //make sure we've got a valid capture controller.
        if (!self.captureController) {
            self.captureController = [[BWSCaptureController alloc] initWithNibName:@"BWSCaptureController" bundle:nil];
            self.captureController.delegate = self;    
            
            //if there's no popover controller, create one.
            if (!capturePopover) {
                capturePopover = [[UIPopoverController alloc] initWithContentViewController:self.captureController];
                //configure this popover's appearance.
                capturePopover.popoverBackgroundViewClass = [GIKPopoverBackgroundView class];
                capturePopover.delegate = self;
            }
            else {
                capturePopover.contentViewController = self.captureController;
            }
        }
        
        //keep a reference to the popover inside the capture controller.
        self.captureController.popoverController = capturePopover;

        
        //give the capture controller a reference to the correct item
        self.captureController.item = targetItem;
                
        //make sure we have the right content size (may be reset elsewhere)
        capturePopover.popoverContentSize = CGSizeMake(480,408);

        //allow the user to interact with anything in this cell's grid view while the popover is active, as well
        //as the add-new-item button. Dismiss if the background is tapped.
        NSMutableArray *passthrough = [NSMutableArray arrayWithArray:self.itemGridView.subviews];
        [passthrough addObject:self.addButton];
        
        capturePopover.passthroughViews = passthrough;
        
        //The sensor associated with this capturer is, hopefully, initialized.
        //Configure it.
        
        BWSDeviceLink *link = [[BWSDeviceLinkManager defaultManager] deviceForUri:targetItem.deviceConfig.uri];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                       [NSKeyedUnarchiver unarchiveObjectWithData:targetItem.deviceConfig.parameterDictionary]];
        [params removeObjectForKey:kBWSDeviceDefinitionParameterKeyStream];
        if (link.initialized) {
            //grab the lock and try to configure the sensor
            [link setConfiguration:link.currentSessionId
                     withParameters:params
                           deviceID:[targetItem.objectID URIRepresentation]];
        }
        else {
            //Something's up, and the sensor was not properly initialized. Try again, starting from reconnecting.
            [link beginConnectConfigureSequenceWithConfigurationParams:params
                            deviceID:[targetItem.objectID URIRepresentation]];
        }
        
        // No way to know the arrow direction until the popover is shown once,
        // so show it, capture the direction, dismiss, adjust the rect, reshow.
        [capturePopover presentPopoverFromRect:showPopoverFromRect
                                        inView:self
                      permittedArrowDirections:direction
                                      animated:NO];
        switch ([capturePopover popoverArrowDirection]) {
            case UIPopoverArrowDirectionDown:
                showPopoverFromRect.origin.x += 95;
                showPopoverFromRect.origin.y += 70;
                break;
            case UIPopoverArrowDirectionUp:
                showPopoverFromRect.origin.x += 92;
                showPopoverFromRect.origin.y += 85;
                break;
            case UIPopoverArrowDirectionLeft:
                showPopoverFromRect.origin.x += 93;
                showPopoverFromRect.origin.y += 72;
                break;
            case UIPopoverArrowDirectionRight:
                showPopoverFromRect.origin.x += 90;
                showPopoverFromRect.origin.y += 72;
                break;
            default:
                break;
        }
        [capturePopover dismissPopoverAnimated:NO];
        [capturePopover presentPopoverFromRect:showPopoverFromRect
                                        inView:self
                      permittedArrowDirections:direction
                                      animated:YES];
        
        //log this
        [activeCell logPopoverControllerPresented:capturePopover];
    }
    else
    {
        DDLogBWSVerbose(@"Tried to show capture popover for an invalid item index: %d",index);
        ((UITableView*)self.superview).scrollEnabled = YES;
    }
}

-(void) showCapturePopoverForItem:(BWSCDItem*) targetItem
{
    [self showCapturePopoverAtIndex:[orderedItems indexOfObject:targetItem]];
}

#pragma mark - GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    CGPoint offsetAtTap = [((UITableView *)[self superview]) contentOffset];
    BWSItemGridCell *currentCell = (BWSItemGridCell*)[gridView cellForItemAtIndex:position];
    
    if (currentCell.selected) {
        //just hide this.
        [capturePopover dismissPopoverAnimated:YES];
        ((UITableView*)self.superview).scrollEnabled = YES;
        [self selectItem:nil];
    }
    else {
        [self showCapturePopoverAtIndex:position];
        // Correct for scroll animation deceleration
        [((UITableView*)[self superview]) setContentOffset:offsetAtTap animated:NO];
    }
}

// Tap on space without any items
- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    //just hide any current selection.
    [capturePopover dismissPopoverAnimated:YES];
    [self selectItem:nil];
}

// Called when the delete-button has been pressed. Required to enable editing mode.
// This method wont delete the cell automatically. Call the delete method of the gridView when appropriate.
- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    deleteItemSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Confirm Delete Item"
                                         otherButtonTitles:nil];
    
    deletableItem = index; //mark this cell for deletion if the user confirms the action.
    
    GMGridViewCell *activeCell;           
    
    // Might return nil if cell not loaded for the specific index
    if ((activeCell = [self.itemGridView cellForItemAtIndex:index])) { 
        [deleteItemSheet showFromRect:activeCell.bounds inView:activeCell animated:YES];
        [activeCell logActionSheetPresented:deleteItemSheet];
    }
    else {
        //default to showing this from the entire view.
        [deleteItemSheet showFromRect:self.bounds inView:self animated:YES];
        [self logActionSheetPresented:deleteItemSheet];
    }

}

#pragma mark - GMGridViewSortingDelegate

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    //disable the gesture recognizers on the main table view.
    ((UITableView*)self.superview).scrollEnabled = NO;
    
    //hide the popover if it's showing
    [capturePopover dismissPopoverAnimated:YES];
    
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

    BWSCDItem *tempItem = [orderedItems objectAtIndex:oldIndex];
    [orderedItems removeObjectAtIndex:oldIndex];
    [orderedItems insertObject:tempItem atIndex:newIndex];
    
    //update the item indices within the now-updated ordered collection
    for (int i = 0; i < [orderedItems count]; i++) {
        BWSCDItem *tempItem = [orderedItems objectAtIndex:i];
        tempItem.index = [NSNumber numberWithInt:i];
    }
    
    //deselect everything
    [self selectItem:nil];
    
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [orderedItems exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    //update the item indices within the now-updated ordered collection
    for (int i = 0; i < [orderedItems count]; i++) {
        BWSCDItem *tempItem = [orderedItems objectAtIndex:i];
        tempItem.index = [NSNumber numberWithInt:i];
    }

}

//#pragma mark - DraggableGridViewTransformingDelegate
//- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation;
//{
//    return CGSizeMake(700, 530);
//}
//
//- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index 
//{
//    UIView *fullView = [[UIView alloc] init];
//    fullView.backgroundColor = [UIColor yellowColor];
//    fullView.layer.masksToBounds = NO;
//    fullView.layer.cornerRadius = 8;
//    
//    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index inInterfaceOrientation:UIInterfaceOrientationPortrait];
//    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
//    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %d", index];
//    label.textAlignment = UITextAlignmentCenter;
//    label.backgroundColor = [UIColor clearColor];
//    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    label.font = [UIFont boldSystemFontOfSize:20];
//    
//    [fullView addSubview:label];
//    
//    
//    return fullView;
//}
//
//- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
//{
//    [UIView animateWithDuration:0.5 
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction 
//                     animations:^{
//                         //cell.contentView.backgroundColor = [UIColor blueColor];
//                         cell.contentView.layer.shadowOpacity = 0.7;
//                     } 
//                     completion:nil];
//}
//
//- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
//{
//    [UIView animateWithDuration:0.5 
//                          delay:0 
//                        options:UIViewAnimationOptionAllowUserInteraction 
//                     animations:^{
//                         //cell.contentView.backgroundColor = [UIColor redColor];
//                         cell.contentView.layer.shadowOpacity = 0;
//                     } 
//                     completion:nil];
//}
//
//- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
//{
//    
//}
//

#pragma mark - UIPopoverController Delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    //disable the grid while we're animating.
//    self.itemGridView.userInteractionEnabled = NO;
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
//    //re-enable user interaction now that we've closed the popover.
//    self.itemGridView.userInteractionEnabled = YES;
    
    ((UITableView*)self.superview).scrollEnabled = YES;

    //make sure nothing is selected.
    [self selectItem:nil];
    
    if (_biographicalDataVisible)
        _biographicalDataVisible = NO;
}

@end
