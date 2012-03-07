//
//  UserTesting.h
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// This class logs touch data. It makes use of the Lumberjack framework (https://github.com/robbiehanson/CocoaLumberjack ),
// which needs to be initialized according to their instructions before the first log statement is called.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DDLog.h"
#import "UIView+FindUIViewController.h"

@interface UIView (Logging)

-(UIImage*) screenshot;

-(void) startAutomaticGestureLogging:(BOOL)recursive;

-(NSString*) baseLogString:(NSString*)eventType withLocalPoint:(CGPoint)localPoint withWindowPoint:(CGPoint)globalPoint;

-(void) tapDetected:(UITapGestureRecognizer*)recog;
-(void) pinchDetected:(UIPinchGestureRecognizer*)recog;

-(void) logTextFieldStarted:(NSIndexPath*)position;
-(void) logTextFieldEnded:(NSIndexPath*)position;
-(void) logTextViewStarted:(NSIndexPath*)position;
-(void) logTextViewEnded:(NSIndexPath*)position;

-(void) logScrollStarted;
-(void) logScrollChanged;
-(void) logScrollEnded;

-(void) logPopoverShownFrom:(UIView*)source;
-(void) logPopoverHidden;

-(void) logActionSheetShown:(BOOL)shownInPopover;
-(void) logActionSheetHidden;

@end
