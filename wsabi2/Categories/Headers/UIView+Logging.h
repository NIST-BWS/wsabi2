//
//  UserTesting.h
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//

// This class logs touch data. It makes use of the Lumberjack framework (https://github.com/robbiehanson/CocoaLumberjack ),
// which needs to be initialized according to their instructions before the first log statement is called.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DDLog.h"
#import "UIView+FindUIViewController.h"

//
// Events
//
static NSString * const UIViewLoggingAppEnteredForeground = @"app entered foreground";
static NSString * const UIViewLoggingAppEnteredBackground = @"app entered background";

static NSString * const UIViewLoggingActionSheetShown = @"action sheet opened";
static NSString * const UIViewLoggingActionSheetShownInPopover = @"action sheet opened in popover";
static NSString * const UIViewLoggingActionSheetClosed = @"action sheet closed";

static NSString * const UIViewLoggingPopoverShown = @"popover opened";
static NSString * const UIViewLoggingPopoverClosed = @"popover closed";

@interface UIView (Logging)

-(UIImage*) screenshot;

-(void) addLongPressGestureLogging:(BOOL)recursive withThreshold:(float)seconds;

-(NSString*) baseLogString:(NSString*)eventType withLocalPoint:(CGPoint)localPoint withWindowPoint:(CGPoint)globalPoint;

-(void) tapDetected:(UITapGestureRecognizer*)recog;
-(void) pinchDetected:(UIPinchGestureRecognizer*)recog;
-(void) longPressDetected:(UILongPressGestureRecognizer*)recog;

-(void) logTextFieldStarted:(NSIndexPath*)position;
-(void) logTextFieldEnded:(NSIndexPath*)position;
-(void) logTextViewStarted:(NSIndexPath*)position;
-(void) logTextViewEnded:(NSIndexPath*)position;

-(void) logScrollStarted;
-(void) logScrollChanged;
-(void) logScrollEnded;

-(void) logPopoverShownFrom:(UIView*)source;
-(void) logPopoverHidden;

-(void) logEnterBackground;
-(void) logEnterForeground;

-(void) logViewPresented;
-(void) logViewDismissed;
-(void) logViewDismissedViaTapAtPoint:(CGPoint)point;

@end
