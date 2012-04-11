//
//  WSItemGridCell.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBCLDeviceLinkManager.h"
#import "GMGridView.h"
#import "WSCDPerson.h"
#import "WSCDItem.h"
#import "WSBiographicalDataController.h"
#import "WSCaptureController.h"
#import "WSItemGridCell.h"
#import "WSModalityChooserController.h"
#import "constants.h"

@protocol WSPersonTableViewCellDelegate <NSObject>

-(void) didRequestDuplicatePerson:(WSCDPerson*)person;
-(void) didRequestDeletePerson:(WSCDPerson*)person;

@end

@interface WSPersonTableViewCell : UITableViewCell <GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate,
                                                    WSBiographicalDataDelegate, WSCaptureDelegate, UIActionSheetDelegate>
{
    BOOL initialLayoutComplete;
    NSMutableArray *orderedItems;
    int deletableItem;
    
    UIActionSheet *deletePersonSheet;
    UIActionSheet *deleteItemSheet;
    
    UIViewController *testVC;
}

-(void) updateData;
-(void) reloadItemGridAnimated:(BOOL)inOrOut;
-(NSString*)biographicalShortName;

-(IBAction)biographicalDataButtonPressed:(id)sender;
-(IBAction)addItemButtonPressed:(id)sender;
-(IBAction)duplicateRowButtonPressed:(id)sender;
-(IBAction)editButtonPressed:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;

-(void) performItemDeletionAtIndex:(int) index;
-(void) showCapturePopoverAtIndex:(int) index;
-(void) showCapturePopoverForItem:(WSCDItem*) targetItem;

//Notification handlers
-(void) handleDownloadPosted:(NSNotification*)notification;

@property (nonatomic, strong) UIPopoverController *popoverController;

@property (nonatomic, strong) WSCDPerson *person;
@property (nonatomic, strong) IBOutlet GMGridView *itemGridView;
@property (nonatomic, strong) IBOutlet UIButton *biographicalDataButton;
@property (nonatomic, strong) IBOutlet UILabel *biographicalDataInactiveLabel;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *duplicateRowButton;

@property (nonatomic, strong) IBOutlet UIImageView *customSelectedBackgroundView;

@property (nonatomic, unsafe_unretained) id<WSPersonTableViewCellDelegate> delegate;

@end
