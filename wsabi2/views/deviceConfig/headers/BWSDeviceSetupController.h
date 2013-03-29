// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import "BWSDeviceLink.h"
#import "BWSConstants.h"
#import "BWSModalityMap.h"
#import "WSBDResult.h"
#import "WSBDParameter.h"
#import "BWSCDDeviceDefinition.h"
#import "BWSCDItem.h"
#import "ELCTextFieldCellWide.h"
#import "BWSModalityChooserController.h"
#import "BWSSubmodalityChooserController.h"

typedef enum {
	kStatusBlank = 0,
    kStatusChecking,
    kStatusNotFound,
    kStatusBadModality,
    kStatusBadSubmodality,
    kStatusSuccessful,
    kStatus_COUNT
} WSSensorSetupStatusType;


@interface BWSDeviceSetupController : UIViewController <UITableViewDataSource, UITableViewDelegate,
                                                        UITextFieldDelegate, BWSDeviceLinkDelegate>
{
    BOOL checkingSensor;
    
    NSTimer *sensorCheckTimer;
    
    //This will be a standalone single link, and won't be connected to 
    //the device link manager, because we don't want to stomp on existing
    //communications, and we only need rapid access to one endpoint (/info).
    BWSDeviceLink *currentLink;
}

-(IBAction)doneButtonPressed:(id)sender;
-(IBAction)cycleButtonPressed:(id)sender;
-(IBAction)checkAgainButtonPressed:(id)sender;
-(IBAction)editAddressButtonPressed:(id)sender;
-(IBAction)changeCaptureTypeButtonPressed:(id)sender;
-(IBAction)tappedBehindView:(id)sender;

//Sensor interaction stuff
-(void) checkSensor:(NSTimer*)timer;

@property (nonatomic, strong) BWSCDItem *item;
@property (nonatomic, strong) BWSCDDeviceDefinition *deviceDefinition;
@property (nonatomic) WSSensorCaptureType submodality;
@property (nonatomic) WSSensorModalityType modality;

//Status stuff
@property (nonatomic) WSSensorSetupStatusType sensorCheckStatus;

@property (nonatomic, strong) IBOutlet UIView *statusContainer;
@property (nonatomic, strong) IBOutlet UIImageView *statusContainerBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton *statusTextButton;

@property (nonatomic, strong) IBOutlet UIView *notFoundContainer;
@property (nonatomic, strong) IBOutlet UIButton *reconnectButton;

@property (nonatomic, strong) IBOutlet UIView *warningContainer;
@property (nonatomic, strong) IBOutlet UIButton *editAddressButton;
@property (nonatomic, strong) IBOutlet UIButton *changeCaptureTypeButton;

@property (nonatomic, strong) IBOutlet UIView *checkingContainer;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *checkingActivity;
@property (nonatomic, strong) IBOutlet UILabel *checkingLabel;

//Table view stuff
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapBehindViewRecognizer;

@end
