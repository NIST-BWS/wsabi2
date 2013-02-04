// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <UIKit/UIKit.h>
#import "BWSConstants.h"

@interface BWSCaptureButton : UIButton

@property (nonatomic) WSCaptureButtonState state;
/*	WSCaptureButtonStateInactive,
 WSCaptureButtonStateCapture,
 WSCaptureButtonStateStop,
 WSCaptureButtonStateWarning,
 WSCaptureButtonStateWaiting,
 WSCaptureButtonStateWaitingRestartCapture,
 */

//@property (nonatomic, strong) UIView *titleBackgroundView;

@property (nonatomic, strong) UIImage *inactiveImage;
@property (nonatomic, strong) UIImage *captureImage;
@property (nonatomic, strong) UIImage *stopImage;
@property (nonatomic, strong) UIImage *warningImage;
@property (nonatomic, strong) UIImage *waitingImage;
@property (nonatomic, strong) UIImage *waitingRestartCaptureImage;

@property (nonatomic, strong) NSString *inactiveMessage;
@property (nonatomic, strong) NSString *captureMessage;
@property (nonatomic, strong) NSString *stopMessage;
@property (nonatomic, strong) NSString *warningMessage;
@property (nonatomic, strong) NSString *waitingMessage;
@property (nonatomic, strong) NSString *waitingRestartCaptureMessage;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSTimer *delayedMessageTimer;

@end
