// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSDDLog.h"
#import "BWSCaptureController.h"
#import "BWSMixedReplaceHTTPRequestOperation.h"
#import "WSBDParameter.h"
#import "WSBDResource.h"

#import "BWSLightboxViewController.h"
#import "BWSAppDelegate.h"


@interface BWSCaptureController ()

@property (nonatomic, strong) NSOperation *streamingOperation;

@end

@implementation BWSCaptureController
@synthesize item;
@synthesize popoverController;

@synthesize frontContainer;
@synthesize backContainer;
@synthesize backNavBarTitleItem;

@synthesize annotationTableView;
@synthesize annotationNotesTableView;
@synthesize annotating;

@synthesize modalityButton;
@synthesize deviceButton;
@synthesize annotateButton;
@synthesize itemDataView;
@synthesize captureButton;
@synthesize delegate;
@synthesize lightboxing;


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
    [super didReceiveMemoryWarning];

    [self stopStream];
}

#pragma mark - Internal convenience methods
-(BOOL) hasAnnotationOrNotes
{
    if (self.item.notes && ![self.item.notes isEqualToString:@""]) {
        return YES;
    }
    
    if (!currentAnnotationArray) {
        return NO;
    }
    
    for (NSNumber *val in currentAnnotationArray) {
        if ([val boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - View lifecycle
-(void) configureView
{
    //We may have to set our properties before everything is loaded, or after.
    //Encapsulate everything here.
    
    if (!self.item) {
        //put the button in the inactive state.
        self.captureButton.state = WSCaptureButtonStateInactive;

        return; //nothing else to update.
    }
    
    ///Load data from the network and Core Data

    //Get a reference to the sensor link for this object.
    currentLink = [[BWSDeviceLinkManager defaultManager] deviceForUri:self.item.deviceConfig.uri];
    
    if (currentLink.sequenceInProgress && !self.item.data) {
        //set the capture button to the waiting state
        self.captureButton.state = WSCaptureButtonStateWaiting;
    }
    else {
        //put the button in the correct normal state.
        self.captureButton.state = self.item.data ? WSCaptureButtonStateInactive : WSCaptureButtonStateCapture;
    }
    
    //configure the annotation button and panel
    //store the annotation array locally for performance.
    if (item.annotations) {
        currentAnnotationArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:item.annotations]];
    }
    else {
        //If there isn't an annotation array, create and fill one.
        int maximumAnnotations = 4;
        currentAnnotationArray = [[NSMutableArray alloc] initWithCapacity:maximumAnnotations]; //the largest (current) submodality
        for (int i = 0; i < maximumAnnotations; i++) {
            [currentAnnotationArray addObject:[NSNumber numberWithBool:NO]];
        }
    }
    //reload the table view
    [self.annotationTableView reloadData];
    [self.annotationNotesTableView reloadData];
    
    if (self.item.data) {
        dataImage = [UIImage imageWithData:self.item.data];
        self.itemDataView.image = dataImage;
    }    
    else {
        self.itemDataView.image = nil;
    }
    
    [self.modalityButton setTitle:self.item.submodality forState:UIControlStateNormal];
    
    if (self.item.deviceConfig.name == nil || [self.item.deviceConfig.name isEqualToString:@""]) {
        if (self.item.deviceConfig.uri == nil || [self.item.deviceConfig.uri isEqualToString:@""])
            [self.deviceButton setTitle:NSLocalizedString(@"<Unnamed>", @"Name for unnamed sensor") forState:UIControlStateNormal];
        else
            [self.deviceButton setTitle:self.item.deviceConfig.uri forState:UIControlStateNormal];
    } else
        [self.deviceButton setTitle:self.item.deviceConfig.name forState:UIControlStateNormal];
    self.deviceButton.enabled = ![self.item.submodality isEqualToString:[BWSModalityMap stringForCaptureType:kCaptureTypeNotSet]];
    
    self.backNavBarTitleItem.title = self.item.submodality;
    self.annotationNotesTableView.alwaysBounceVertical = NO;

    [[self backContainer] setHidden:NO];
    [[self frontContainer] setHidden:NO];
    
    [self updateAnnotationLabel];
    
    if (self.itemDataView.image == nil) {
        [[self deviceButton] setEnabled:YES];
        [[self modalityButton] setEnabled:YES];
    } else {
        [[self deviceButton] setEnabled:NO];
        [[self modalityButton] setEnabled:NO];
    }
    
    [self showFrontSideAnimated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.modalityButton setBackgroundImage:[[UIImage imageNamed:@"BreadcrumbButton"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateNormal];
    [self.deviceButton setBackgroundImage:[[UIImage imageNamed:@"BreadcrumbButtonEndCap"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateNormal];
    
    //Configure the capture button.
    /*	WSCaptureButtonStateInactive,
     WSCaptureButtonStateCapture,
     WSCaptureButtonStateStop,
     WSCaptureButtonStateWarning,
     WSCaptureButtonStateWaiting,
     WSCaptureButtonStateWaitingRestartCapture,
     */

//    //add a mostly-opaque white background behind the capture button's label and image.
//    UIView *capBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)]; //arbitrary size, this will be set later inside the button.
//    capBG.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7]; 
//    self.captureButton.titleBackgroundView = capBG;

    self.captureButton.inactiveImage = [UIImage imageNamed:@"Blank"];
    self.captureButton.inactiveMessage = @"";

    self.captureButton.captureImage = [UIImage imageNamed:@"gesture-single-tap"];
    
    self.captureButton.stopImage = [UIImage imageNamed:@"stop-sign"];
    self.captureButton.stopMessage = @"Stop capture";
    
    self.captureButton.warningImage = [UIImage imageNamed:@"warning-alert"];
    self.captureButton.warningMessage = @"There's a problem communicating with the sensor.";
    
    self.captureButton.waitingMessage = @"Waiting for sensor";
    
    self.captureButton.waitingRestartCaptureMessage = @"Reconnecting to the sensor";

    //add swipe listeners to the capture button to switch between items.
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeCaptureButton:)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:swipeRight];
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeCaptureButton:)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.view addGestureRecognizer:swipeLeft];


    [[self annotationTableView] setAccessibilityLabel:@"Annotations"];
    
    lightboxing = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Touch logging
    [[self modalityButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self deviceButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self annotateButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self modalityButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self captureButton] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self annotationTableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self annotationTableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeScroll];
    [[self annotationNotesTableView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[self itemDataView] startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
    [[[self view] window] addGestureRecognizer:[self tapBehindViewRecognizer]];
    [[self itemDataView] addGestureRecognizer:[self doubleTapRecognizer]];
    
    //
    //add notification listeners
    //
    
    //Catch a newly connected sensor
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleConnectCompleted:)
                                                 name:kSensorLinkConnectSequenceCompleted
                                               object:nil];
    
    //Catch operation completed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOperationCompleted:)
                                                 name:kSensorLinkOperationCompleted
                                               object:nil];
    
    //Catch a posted download
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDownloadPosted:)
                                                 name:kSensorLinkDownloadPosted
                                               object:nil];
    //Catch an item change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleItemChanged:)
                                                 name:kChangedWSCDItemNotification
                                               object:nil];
    
    //Catch a failed sensor operation
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSensorOperationFailed:)
                                                 name:kSensorLinkOperationFailed
                                               object:nil];
    
    //Catch a failed sensor sequence
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSensorSequenceFailed:)
                                                 name:kSensorLinkSequenceFailed
                                               object:nil];
    lightboxing = NO;

    [self startStream];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Remove recognizer when view isn't visible
    [[[self view] window] removeGestureRecognizer:[self tapBehindViewRecognizer]];


    // Cancel existing capture requests
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsCancelCaptureOnDismiss]) {
        BWSDeviceLink *deviceLink = [[BWSDeviceLinkManager defaultManager] deviceForUri:item.deviceConfig.uri];
        if ([deviceLink operationInProgress] == kOpTypeCapture) {
            DDLogBWSVerbose(@"%@", @"CaptureController closing while Capture command active.  Attempting to cancel...");
            [deviceLink cancel:deviceLink.currentSessionId deviceID:[item.objectID URIRepresentation]];
        }
    }

    [self stopStream];

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Touch logging
    [[self modalityButton] stopLoggingBWSInterfaceEvents];
    [[self deviceButton] stopLoggingBWSInterfaceEvents];
    [[self annotateButton] stopLoggingBWSInterfaceEvents];
    [[self modalityButton] stopLoggingBWSInterfaceEvents];
    [[self captureButton] stopLoggingBWSInterfaceEvents];
    [[self annotationTableView] stopLoggingBWSInterfaceEvents];
    [[self annotationNotesTableView] stopLoggingBWSInterfaceEvents];
    [[self itemDataView] stopLoggingBWSInterfaceEvents];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(CGSize) contentSizeForViewInPopover
{
    return CGSizeMake(480, 408);
}

-(void) updateAnnotationLabel
{
    NSUInteger annotationCount = 0;
    for (NSNumber *num in currentAnnotationArray)
        if ([num boolValue] == YES)
            annotationCount++;
    // Note counts as an annotation
    if (self.item.notes && ![self.item.notes isEqualToString:@""])
        annotationCount++;
    
    if (annotationCount == 0)
        [[self annotationPresentImageView] setHidden:YES];
    else
        [[self annotationPresentImageView] setHidden:NO];

}

-(void)showFlipSideAnimated:(BOOL)animated
{
    [[self backContainer] setFrame:[[self view] frame]];
    [UIView transitionFromView:[self frontContainer]
                        toView:[self backContainer]
                      duration:(animated ? kFlipAnimationDuration : 0)
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil
     ];
    
    annotating = YES;
}

-(void)showFrontSideAnimated:(BOOL)animated
{
    [[self frontContainer] setFrame:[[self view] frame]];
    //make sure we resign first responder.
    [self.view endEditing:YES];
    
    //just flip to the capture view.
    //NOTE: For a reason I just can't figure out, the contents of the data UIImageView are getting dumped when the view is flipped
    //and hidden. This works identically when hiding the view using UIView's built-in transition methods. It works identically
    //when keeping a reference to the contained UIImage as an ivar as when loading it directly from the WSCDItem. It works identically
    //when setting the UIImageView to clear its contents and not. For the moment, we'll reset the image manually when it appears.
    if (self.item.data) {
        //this makes for a smoother transition.
        self.itemDataView.backgroundColor = [UIColor darkGrayColor];
    }
    
    void (^completion)(BOOL completed) = ^(BOOL completed) {
        if (self.item.data) {
            self.itemDataView.alpha = 0;
            self.itemDataView.image = dataImage;
            [UIView animateWithDuration:(animated ? 0.1 : 0)
                             animations:^{
                                 self.itemDataView.alpha = 1.0;
                                 self.itemDataView.backgroundColor = [UIColor whiteColor];
                             }
             ];
        }
    };
    
    [UIView transitionFromView:[self backContainer]
                        toView:[self frontContainer]
                      duration:(animated ? kFlipAnimationDuration : 0)
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:completion
     ];

    //save the context
    [(BWSAppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    //Post a notification that this item has changed
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item,kDictKeyTargetItem,
                              [self.item.objectID URIRepresentation],kDictKeyDeviceID, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangedWSCDItemNotification
                                                        object:self
                                                      userInfo:userInfo];
    
    
    [self updateAnnotationLabel];
    annotating = NO;
}

#pragma mark - Property accessors
-(void) setItem:(BWSCDItem *)newItem
{
    item = newItem;
    
    [self configureView];
}


#pragma mark - Button Action Methods

-(IBAction)annotateButtonPressed:(id)sender
{
    if (self.item.data) {
        annotateClearActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:@"Clear this image"
                                                      otherButtonTitles:@"Annotate", nil];
        annotateClearActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [annotateClearActionSheet showInView:self.view];
    } else {
        //just flip to the annotation.
        [self showFlipSideAnimated:YES];
        [self.frontContainer logViewDismissed];
        [self.backContainer logViewPresented];
    }
}

-(IBAction)doneButtonPressed:(id)sender
{
    [self showFrontSideAnimated:YES];
    [self.backContainer logViewDismissed];
    [self.frontContainer logViewPresented];
}

-(IBAction)modalityButtonPressed:(id)sender
{
//    [delegate didRequestModalityChangeForItem:self.item];

    //Post a notification to show the modality walkthrough
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item, kDictKeyTargetItem, [NSNumber numberWithBool:YES], kDictKeyStartFromSubmodality, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];

    //close the popover
    [self.popoverController dismissPopoverAnimated:YES];
}

-(IBAction)deviceButtonPressed:(id)sender
{
//    [delegate didRequestDeviceChangeForItem:self.item];

    //Post a notification to show the modality walkthrough starting from device selection.
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item,kDictKeyTargetItem,[NSNumber numberWithBool:YES],kDictKeyStartFromDevice,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowWalkthroughNotification
                                                        object:self
                                                      userInfo:userInfo];

    //close the popover
    [self.popoverController dismissPopoverAnimated:YES];
}

-(IBAction)captureButtonPressed:(id)sender
{    
    //[self stopStream];

    //Try to capture.
    //Post a notification to start capture, starting from this item
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item,kDictKeyTargetItem,
                              [self.item.objectID URIRepresentation],kDictKeyDeviceID, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartCaptureNotification
                                                        object:self
                                                      userInfo:userInfo];

    //Update our state (temporarily, just cycle states).
    self.captureButton.state = fmod((self.captureButton.state + 1), WSCaptureButtonStateWaiting_COUNT);
    self.captureButton.state = WSCaptureButtonStateWaiting;
}
                                       
#pragma mark - Gesture recognizer handlers
-(void) didSwipeCaptureButton:(UISwipeGestureRecognizer*)recog
{
    if (recog.direction == UISwipeGestureRecognizerDirectionLeft) {
        //go to the previous item
        [delegate didRequestCapturePreviousItem:self.item];
    }
    else if (recog.direction == UISwipeGestureRecognizerDirectionRight) {
        //go to the next item
        [delegate didRequestCaptureNextItem:self.item];
    }
        
}

#pragma mark - UIActionSheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Clear, annotate, cancel
    if (actionSheet == annotateClearActionSheet) {
        // Clear image
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Remove the previous ActionSheet
            [annotateClearActionSheet dismissWithClickedButtonIndex:actionSheet.destructiveButtonIndex animated:YES];
            
            //show another action sheet to confirm the deletion
            deleteConfirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Clear this image?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:@"Clear"
                                                          otherButtonTitles:nil];
            deleteConfirmActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [deleteConfirmActionSheet showInView:self.view];
        // Annotate
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self showFlipSideAnimated:YES];
            [self.frontContainer logViewDismissed];
            [self.backContainer logViewPresented];
        }
    // Clear, cancel
    } else if (actionSheet == deleteConfirmActionSheet) {
        // Clear
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            // Remove data and set the capture button state.
            self.item.data = nil;
            self.item.dataContentType = nil;
            [(BWSAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
            
            //Post a notification that this item has changed
            NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.item,kDictKeyTargetItem,
                                      [self.item.objectID URIRepresentation],kDictKeyDeviceID, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangedWSCDItemNotification
                                                                object:self
                                                              userInfo:userInfo];
            self.captureButton.state = WSCaptureButtonStateCapture;
        }
    }
}

#pragma mark - Notification handlers

-(void) handleOperationCompleted:(NSNotification *)notification
{
    NSNumber *opType = [notification.userInfo objectForKey:kDictKeyOperation];
    
    if ([opType integerValue] == kOpTypeCapture)
    {
        [self stopStream];
    }
}
-(void) handleConnectCompleted:(NSNotification *)notification
{
    NSMutableDictionary *info = (NSMutableDictionary*)notification.userInfo;
    
    DDLogBWSNetwork(@"userInfo for connect sequence is %@",info.description);
    
    BWSDeviceLink *sourceLink = [info objectForKey:kDictKeySourceLink];
    
    //If this applies to us, change our capture state.
    if (currentLink == sourceLink) {
        self.captureButton.state = self.item.data ? WSCaptureButtonStateInactive : WSCaptureButtonStateCapture;
    }
}

-(void) handleItemChanged:(NSNotification*)notification
{
    //At the moment, this is mainly used to catch a deletion, but may also be used to catch any time
    //the item changes out from under us.
    
    //Do this in the most simpleminded way possible
    NSMutableDictionary *info = (NSMutableDictionary*)notification.userInfo;
    
    BWSCDItem *targetItem = (BWSCDItem*) [self.item.managedObjectContext objectWithID:[self.item.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[info objectForKey:kDictKeyDeviceID]]];

    //Catch a change to the item state.
    if (self.item == targetItem) {
        if ([info objectForKey:@"data"]) {
            //the table view is going to take care of editing the actual data, we just need to use
            //the image.
            dataImage = [UIImage imageWithData:[info objectForKey:@"data"]];
            self.itemDataView.image = dataImage;
        }
        else {
            self.itemDataView.image = nil;
        }
    }
}

-(void) handleDownloadPosted:(NSNotification*)notification
{
    //Do this in the most simpleminded way possible
    NSMutableDictionary *info = (NSMutableDictionary*)notification.userInfo;
    
    BWSCDItem *targetItem = (BWSCDItem*) [self.item.managedObjectContext objectWithID:[self.item.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[info objectForKey:kDictKeyDeviceID]]];
    
    if (self.item == targetItem && [info objectForKey:@"data"]) {
        //the table view is going to take care of editing the actual data, we just need to use
        //the image.
        dataImage = [UIImage imageWithData:[info objectForKey:@"data"]];
        self.itemDataView.image = dataImage;
    }
    
    //return the capture state to normal or hidden
    if(self.itemDataView.image)
    {
        self.captureButton.state = WSCaptureButtonStateInactive;
    }
    else {
        self.captureButton.state = WSCaptureButtonStateCapture;

    }
}

-(void) handleSensorOperationFailed:(NSNotification*)notification
{
    //Do this in the most simpleminded way possible
    NSMutableDictionary *info = (NSMutableDictionary*)notification.userInfo;
    NSError *error = [info objectForKey:@"error"];
    BWSCDItem *targetItem;
    
    if ([info objectForKey:kDictKeyDeviceID]) {
        targetItem = (BWSCDItem*) [self.item.managedObjectContext objectWithID:[self.item.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[info objectForKey:kDictKeyDeviceID]]];
    }
    
    if (targetItem && item != targetItem) {
        return; //this doesn't apply to us.
    }
    
    //IF the capture button is visible:
    if (self.captureButton.state != WSCaptureButtonStateInactive) {
        self.captureButton.state = WSCaptureButtonStateWarning;
        self.captureButton.warningMessage = error.localizedDescription;
    }
    else {
        //Log the error but don't change the UI
        DDLogBWSVerbose(@"Ran into a failed sensor sequence: %@",error.description);
    }

}

-(void) handleSensorSequenceFailed:(NSNotification *)notification
{
    //Do this in the most simpleminded way possible
    NSMutableDictionary *info = (NSMutableDictionary*)notification.userInfo;
    
//    WSCDItem *targetItem = (WSCDItem*) [self.item.managedObjectContext objectWithID:[self.item.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[info objectForKey:kDictKeyDeviceID]]];
//
//    //Make sure this applies to us.
//    if (self.item == targetItem) {
//        
    WSBDResult *result = (WSBDResult*)[info objectForKey:kDictKeyCurrentResult];
    NSString *resultString = [NSString stringWithFormat:@"Sensor problem: %@", result.message ? result.message : [WSBDResult stringForStatusValue:result.status]];   
        
    BWSCDItem *targetItem;
    
    if ([info objectForKey:kDictKeyDeviceID]) {
        targetItem = (BWSCDItem*) [self.item.managedObjectContext objectWithID:[self.item.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[info objectForKey:kDictKeyDeviceID]]];
    }
    
    if (targetItem && item != targetItem) {
        return; //this doesn't apply to us.
    }

    //IF the capture button is visible:
    if (self.captureButton.state != WSCaptureButtonStateInactive) {
        //This is a failed capture notification, so change our button state.
        self.captureButton.warningMessage = resultString;
        self.captureButton.state = WSCaptureButtonStateWarning;
    }
    else {
        //Log the error but don't change the UI
        DDLogBWSVerbose(@"Ran into a failed sensor sequence: %@",resultString);
    }

//        }
//    }
}

- (IBAction)tappedBehindView:(UITapGestureRecognizer *)sender;
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // Get coordinates in the window of tap
        CGPoint location = [sender locationInView:nil];
        
        // Check if tap was within view
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil]) {
            [[[self view] window] removeGestureRecognizer:[self tapBehindViewRecognizer]];
            [self.view logPopoverControllerDismissed:self.popoverController viaTapAtPoint:location];
        }
    }
}

- (IBAction)doubleTappedImage:(UITapGestureRecognizer *)sender
{
    [self showLightbox];
}

- (void)showLightbox
{
    if (self.itemDataView.image == nil) {
        DDLogBWSVerbose(@"%@", @"Refusing to show lightbox for unset image.");
        return;
    }
    
    BWSLightboxViewController *vc = [[BWSLightboxViewController alloc] initWithNibName:@"BWSLightboxView" bundle:nil];
    [vc setImage:self.itemDataView.image];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:vc animated:YES completion:^() {
        lightboxing = YES;
    }];
}

- (void)didLeaveLightboxMode
{
    lightboxing = NO;
}

#pragma mark - TableView data source/delegate
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.annotationNotesTableView) {
        return 1;
    }
    
    WSSensorCaptureType capType = [BWSModalityMap captureTypeForString:item.submodality];
    
    if (capType == kCaptureTypeLeftSlap || capType == kCaptureTypeRightSlap) {
        return 4;
    }
    else if (capType == kCaptureTypeThumbsSlap || 
             capType == kCaptureTypeBothEars ||
             capType == kCaptureTypeBothFeet ||
             capType == kCaptureTypeBothIrises ||
             capType == kCaptureTypeBothRetinas)
    {
        return 2;
    }
    else return 1; //all other capture types
}

// Customize the appearance of table view cells.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.annotationNotesTableView) {
        return 300;
    }
    else return 44; //default row height;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.annotationNotesTableView) {
        return @"Notes";
    }
    
    else return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StringCell = @"StringCell"; 
    static NSString *TextViewCell = @"TextViewCell";
    
    if (aTableView == self.annotationTableView) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:StringCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextViewCell];
        }
        
        WSSensorCaptureType capType = [BWSModalityMap captureTypeForString:item.submodality];
        NSString *titleString = nil;
        if (capType == kCaptureTypeLeftSlap || capType == kCaptureTypeRightSlap) {
            switch (indexPath.row) {
                case 0:
                    titleString = @"Index";
                    break;
                case 1:
                    titleString = @"Middle";
                    break;
                case 2:
                    titleString = @"Ring";
                    break;
                case 3:
                    titleString = @"Little";
                    break;
                default:
                    break;
            }
        }
        else if (capType == kCaptureTypeThumbsSlap || 
                 capType == kCaptureTypeBothEars ||
                 capType == kCaptureTypeBothFeet ||
                 capType == kCaptureTypeBothIrises ||
                 capType == kCaptureTypeBothRetinas)
        {
            switch (indexPath.row) {
                case 0:
                    titleString = @"Left";
                    break;
                case 1:
                    titleString = @"Right";
                    break;
                default:
                    break;
            }

        }
        else {
            titleString = item.submodality;
        }
        
        cell.textLabel.text = titleString;
        
        if ([[currentAnnotationArray objectAtIndex:indexPath.row] boolValue]) {
            //if there is an annotation, use the "Not OK" symbol.
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-notok"]];
        }
        else {
            cell.accessoryView = nil;
        }
        
        cell.accessibilityLabel = cell.textLabel.text;
        [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        return cell;
    }
    else if (aTableView == self.annotationNotesTableView) {
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
        textView.text = self.item.notes;  
        textView.accessibilityLabel = @"Notes";
        [textView setUserInteractionEnabled:YES];
        [textView startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        
        //Disables UITableViewCell from accidentally becoming selected.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
        return cell;
    }

    return nil;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==  UITableViewCellEditingStyleDelete)
        [[tableView cellForRowAtIndexPath:indexPath] stopLoggingBWSInterfaceEvents];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (aTableView != self.annotationTableView) {
        return; //only respond to selections from this one table view.
    }
    
    //mark this row as either annotated or not.
    BOOL existingValue = [[currentAnnotationArray objectAtIndex:indexPath.row] boolValue];
    [currentAnnotationArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!existingValue]];
    
    //reload this row.
    [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //store the changes
    self.item.annotations = [NSKeyedArchiver archivedDataWithRootObject:currentAnnotationArray];
    
    //deselect the row afterwards
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView logTextEntryBegan];
    
    // Apple removes gesture recognizers when becoming first responder
    [textView startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.item.notes = textView.text;
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    [textView logTextEntryEnded];
    
    // Apple removes gesture recognizers when resigning first responder
    [textView startLoggingBWSInterfaceEventType:kBWSInterfaceEventTypeTap];
}

#pragma mark - Streaming

- (void)startStream
{
    if (self.item.data != nil)
        return;

    NSDictionary *parameters = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:self.item.deviceConfig.parameterDictionary];
    if (parameters == nil)
        return;
	WSBDParameter *streamingParameter = [parameters objectForKey:kBWSDeviceDefinitionParameterKeyStream];
    if (streamingParameter == nil) {
        DDLogBWSVerbose(@"Streaming not supported for device '%@'", self.item.deviceConfig.name);
        NSLog(@"%@", parameters);
        return;
    }

    if ([streamingParameter defaultValue] == nil) {
        DDLogBWSVerbose(@"Streaming supported, but no default streaming configuration given for device '%@'", self.item.deviceConfig.name);
        return;
	}

    BWSDeviceLink *deviceLink = [[BWSDeviceLinkManager defaultManager] deviceForUri:self.item.deviceConfig.uri];
    self.streamingOperation = [deviceLink streamForDeviceID:[self.item.deviceConfig.objectID URIRepresentation]
                                               withResource:[streamingParameter defaultValue]
                                            newDataReceived:^(NSData *responseData) { self.itemDataView.image = [UIImage imageWithData:responseData]; }
                                                    success:nil
                                                    failure:nil];
}

- (void)stopStream
{
	if (self.streamingOperation != nil)
		[self.streamingOperation cancel];
    self.itemDataView.image = nil;
}

@end
