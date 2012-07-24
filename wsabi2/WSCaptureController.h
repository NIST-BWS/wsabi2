//
//  WSCaptureController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/27/12.
 
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "WSModalityMap.h"
#import "WSCaptureButton.h"
#import "NBCLDeviceLinkManager.h"
#import "constants.h"
#import "UIView+FlipTransition.h"

#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "BlockTextPromptAlertView.h"

@protocol WSCaptureDelegate <NSObject>

-(void) didRequestCapturePreviousItem:(WSCDItem*)currentItem;
-(void) didRequestCaptureNextItem:(WSCDItem*)currentItem;

@end

@interface WSCaptureController : UIViewController <UITextViewDelegate, UIActionSheetDelegate>
{

    NBCLDeviceLink *currentLink;
    NSMutableArray *currentAnnotationArray;
    BOOL frontVisible;
    
    UIActionSheet *annotateClearActionSheet;
    UIActionSheet *deleteConfirmActionSheet;
    
    UIImage *dataImage;
    
    NSArray *storedPassthroughViews;
}

-(void) configureView;

-(IBAction)annotateButtonPressed:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;
-(IBAction)modalityButtonPressed:(id)sender;
-(IBAction)deviceButtonPressed:(id)sender;
-(IBAction)captureButtonPressed:(id)sender;

-(void) didSwipeCaptureButton:(UISwipeGestureRecognizer*)recog;

//Notification handlers
-(void) handleConnectCompleted:(NSNotification*)notification;
-(void) handleDownloadPosted:(NSNotification*)notification;
-(void) handleItemChanged:(NSNotification*)notification;
-(void) handleSensorOperationFailed:(NSNotification*)notification;
-(void) handleSensorSequenceFailed:(NSNotification*)notification;

@property (nonatomic, strong) WSCDItem *item;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) IBOutlet UIView *frontContainer;
@property (nonatomic, strong) IBOutlet UIView *backContainer;
@property (nonatomic, strong) IBOutlet UINavigationItem *backNavBarTitleItem;

@property (nonatomic, strong) IBOutlet UITableView *annotationTableView;
@property (nonatomic, strong) IBOutlet UITableView *annotationNotesTableView;
@property (nonatomic, strong) IBOutlet UIButton *annotateButton;

@property (nonatomic, strong) IBOutlet UIButton *modalityButton;
@property (nonatomic, strong) IBOutlet UIButton *deviceButton;
@property (nonatomic, strong) IBOutlet UIImageView *itemDataView;
@property (nonatomic, strong) IBOutlet WSCaptureButton *captureButton;

@property (nonatomic, unsafe_unretained) id<WSCaptureDelegate> delegate;

@end
