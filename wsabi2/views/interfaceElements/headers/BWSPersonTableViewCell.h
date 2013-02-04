// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "BWSDeviceLinkManager.h"
#import "GMGridView.h"
#import "BWSCDPerson.h"
#import "BWSCDItem.h"
#import "BWSBiographicalDataController.h"
#import "BWSCaptureController.h"
#import "BWSItemGridCell.h"
#import "BWSModalityChooserController.h"
#import "BWSPopoverBackgroundView.h"
#import "BWSConstants.h"

@protocol BWSPersonTableViewCellDelegate <NSObject>

-(void) didRequestDuplicatePerson:(BWSCDPerson*)person;
-(void) didRequestDeletePerson:(BWSCDPerson*)person;
-(void) didChangeEditingStatusForPerson:(BWSCDPerson*)person newStatus:(BOOL)onOrOff;
@end

@interface BWSPersonTableViewCell : UITableViewCell <GMGridViewDataSource, GMGridViewSortingDelegate,    
                                                     GMGridViewActionDelegate,
                                                    BWSBiographicalDataDelegate, BWSCaptureDelegate,
                                                    UIPopoverControllerDelegate, UIActionSheetDelegate>
{
    BOOL initialLayoutComplete;
    NSMutableArray *orderedItems;
    int deletableItem;
    NSDateFormatter *dateFormatter;
    
    UIActionSheet *deletePersonSheet;
    UIActionSheet *deleteItemSheet;
        
    UIColor *normalBGColor;
    UIColor *selectedBGColor;
    
    UIPopoverController *capturePopover;
    UIPopoverController *biographicalPopover;
}

-(void) updateData;
-(void) layoutGrid;
-(void) removeBackingStoreForItem:(id)userInfo;
-(void) removeItem:(int)itemIndex animated:(BOOL)animated;
-(NSString*)biographicalShortName;

-(IBAction)biographicalDataButtonPressed:(id)sender;
-(IBAction)addItemButtonPressed:(id)sender;
-(IBAction)duplicateRowButtonPressed:(id)sender;
-(IBAction)editButtonPressed:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)deletePersonOverlayDeletePersonButtonPressed:(id)sender;
-(IBAction)deletePersonOverlayCancelButtonPressed:(id)sender;

-(void) showCapturePopoverAtIndex:(int) index;
-(void) showCapturePopoverForItem:(BWSCDItem*) targetItem;

-(void) selectItem:(BWSItemGridCell*)cellToSelect;

//Notification handlers
-(void) didChangeItem:(NSNotification*)notification;
-(void) handleDownloadPosted:(NSNotification*)notification;

@property (nonatomic, strong) BWSCDPerson *person;
@property (nonatomic, strong) IBOutlet GMGridView *itemGridView;
@property (nonatomic, strong) IBOutlet UIButton *biographicalDataButton;
@property (nonatomic, strong) IBOutlet UILabel *biographicalDataInactiveLabel;
@property (nonatomic, strong) IBOutlet UILabel *timestampLabel;
@property (nonatomic, strong) IBOutlet UILabel *timestampInactiveLabel;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *duplicateRowButton;

@property (nonatomic, strong) IBOutlet BWSCaptureController *captureController;
@property (nonatomic, readonly, assign) int selectedIndex;

@property (nonatomic, strong) IBOutlet UIView *customSelectedBackgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *shadowUpView;
@property (nonatomic, strong) IBOutlet UIImageView *shadowDownView;

@property (nonatomic, strong) IBOutlet UIView *deletePersonOverlayView;
@property (weak, nonatomic) IBOutlet UIButton *deletePersonOverlayViewCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *deletePersonOverlayViewDeleteButton;
@property (nonatomic, strong) IBOutlet UIView *separatorView;


@property (nonatomic, unsafe_unretained) id<BWSPersonTableViewCellDelegate> delegate;

@end
