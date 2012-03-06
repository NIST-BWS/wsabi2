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

@interface UIView (Logging)

-(UIImage*) screenshot;

-(void) startGestureLogging:(BOOL)recursive;

-(void) tapDetected:(UITapGestureRecognizer*)recog;
-(void) pinchDetected:(UIPinchGestureRecognizer*)recog;

-(void) logScrollStarted:(UIScrollView*)scrollView;
-(void) logScrollChanged:(UIScrollView*)scrollView;
-(void) logScrollEnded:(UIScrollView*)scrollView;

@end
