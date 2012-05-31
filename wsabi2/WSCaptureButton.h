//
//  WSCaptureButton.h
//  wsabi2
//
//  Created by Matt Aronoff on 2/29/12.
 
//

#import <UIKit/UIKit.h>
#import "constants.h"

@interface WSCaptureButton : UIButton

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
