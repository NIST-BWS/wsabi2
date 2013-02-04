//
//  WSCaptureController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/27/12.
 
//

#import <UIKit/UIKit.h>
#import "WSCDItem.h"
#import "WSCDDeviceDefinition.h"
#import "BWSModalityMap.h"
#import "BWSCaptureButton.h"
#import "BWSDeviceLinkManager.h"
#import "BWSConstants.h"

@protocol WSCaptureDelegate <NSObject>

-(void) didRequestCapturePreviousItem:(WSCDItem*)currentItem;
-(void) didRequestCaptureNextItem:(WSCDItem*)currentItem;

@end

@interface WSCaptureController : UIViewController <UITextViewDelegate, UIActionSheetDelegate>
{

    BWSDeviceLink *currentLink;
    NSMutableArray *currentAnnotationArray;
    BOOL frontVisible;
    
    UIActionSheet *annotateClearActionSheet;
    UIActionSheet *deleteConfirmActionSheet;
    
    UIImage *dataImage;
    
    NSArray *storedPassthroughViews;
}

-(void) configureView;
-(void) showFrontSideAnimated:(BOOL)animated;
-(void) showFlipSideAnimated:(BOOL)animated;

-(IBAction)annotateButtonPressed:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;
-(IBAction)modalityButtonPressed:(id)sender;
-(IBAction)deviceButtonPressed:(id)sender;
-(IBAction)captureButtonPressed:(id)sender;
-(IBAction)tappedBehindView:(UITapGestureRecognizer *)sender;
-(IBAction)doubleTappedImage:(UITapGestureRecognizer *)sender;
-(void)showLightbox;
-(void)didLeaveLightboxMode;

-(void) didSwipeCaptureButton:(UISwipeGestureRecognizer*)recog;
-(void) updateAnnotationLabel;

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
@property (nonatomic, assign, readonly, getter=isAnnotating) BOOL annotating;

@property (nonatomic, strong) IBOutlet UIButton *modalityButton;
@property (nonatomic, strong) IBOutlet UIButton *deviceButton;
@property (nonatomic, weak) IBOutlet UIButton *annotateButton;
@property (nonatomic, strong) IBOutlet UIImageView *itemDataView;
@property (nonatomic, strong) IBOutlet BWSCaptureButton *captureButton;
@property (weak, nonatomic) IBOutlet UIImageView *annotationPresentImageView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapBehindViewRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, assign, readonly, getter=isLightboxing) BOOL lightboxing;


@property (nonatomic, unsafe_unretained) id<WSCaptureDelegate> delegate;

@end
