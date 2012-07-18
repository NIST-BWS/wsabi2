//
//  WSItemGridCell.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
 
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "NBCLDeviceLinkManager.h"
#import "GMGridView.h"
#import "WSCDPerson.h"
#import "WSCDItem.h"
#import "WSBiographicalDataController.h"
#import "WSCaptureController.h"
#import "WSItemGridCell.h"
#import "WSModalityChooserController.h"
#import "WSPopoverBackgroundView.h"
#import "constants.h"

@protocol WSPersonTableViewCellDelegate <NSObject>

-(void) didRequestDuplicatePerson:(WSCDPerson*)person;
-(void) didRequestDeletePerson:(WSCDPerson*)person;
-(void) didChangeEditingStatusForPerson:(WSCDPerson*)person newStatus:(BOOL)onOrOff;
@end

@interface WSPersonTableViewCell : UITableViewCell <GMGridViewDataSource, GMGridViewSortingDelegate,    
                                                     GMGridViewActionDelegate,
                                                    WSBiographicalDataDelegate, WSCaptureDelegate,
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
    
    int selectedIndex;
    
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
-(void) showCapturePopoverForItem:(WSCDItem*) targetItem;

-(void) selectItem:(WSItemGridCell*)exceptThisOne;

//Notification handlers
-(void) didChangeItem:(NSNotification*)notification;
-(void) handleDownloadPosted:(NSNotification*)notification;

@property (nonatomic, strong) WSCDPerson *person;
@property (nonatomic, strong) IBOutlet GMGridView *itemGridView;
@property (nonatomic, strong) IBOutlet UIButton *biographicalDataButton;
@property (nonatomic, strong) IBOutlet UILabel *biographicalDataInactiveLabel;
@property (nonatomic, strong) IBOutlet UILabel *timestampLabel;
@property (nonatomic, strong) IBOutlet UILabel *timestampInactiveLabel;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *duplicateRowButton;

@property (nonatomic, strong) IBOutlet WSCaptureController *captureController;

@property (nonatomic, strong) IBOutlet UIView *customSelectedBackgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *shadowUpView;
@property (nonatomic, strong) IBOutlet UIImageView *shadowDownView;

@property (nonatomic, strong) IBOutlet UIView *deletePersonOverlayView;
@property (nonatomic, strong) IBOutlet UIView *separatorView;


@property (nonatomic, unsafe_unretained) id<WSPersonTableViewCellDelegate> delegate;

@end
