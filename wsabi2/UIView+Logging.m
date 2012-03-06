//
//  UserTesting.m
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+Logging.h"
#import <objc/runtime.h>

@implementation UIView (Logging)

static char const * const TouchLoggingKey = "TouchLogging";
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

//Implement a logging listener to every touch event passed through this window

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
//{
//
//    //if (self.touchLoggingEnabled) {
//        UITouch *aTouch = [touches anyObject];
//        
//        CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
//        
//        NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
//                               [self class], 
//                               convertedFrame.origin.x,
//                               convertedFrame.origin.y,
//                               convertedFrame.size.width,
//                               convertedFrame.size.height,
//                               [aTouch locationInView:self.window].x, 
//                               [aTouch locationInView:self.window].y,
//                               @"touch down"];
//        
//        DDLogError(logString);
//    //}
//    
//    [super touchesBegan:touches withEvent:event];
//
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//    //if (self.touchLoggingEnabled) {
//        UITouch *aTouch = [touches anyObject];
//        
//        CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
//        
//        NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
//                               [self class], 
//                               convertedFrame.origin.x,
//                               convertedFrame.origin.y,
//                               convertedFrame.size.width,
//                               convertedFrame.size.height,
//                               [aTouch locationInView:self.window].x, 
//                               [aTouch locationInView:self.window].y,
//                               @"touch moved"];
//        
//        DDLogError(logString);
//
//    //}
//
//    [super touchesMoved:touches withEvent:event];
//
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//    //if (self.touchLoggingEnabled) {
//        UITouch *aTouch = [touches anyObject];
//        
//        CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
//        
//        NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
//                               [self class], 
//                               convertedFrame.origin.x,
//                               convertedFrame.origin.y,
//                               convertedFrame.size.width,
//                               convertedFrame.size.height,
//                               [aTouch locationInView:self.window].x, 
//                               [aTouch locationInView:self.window].y,
//                               @"touch ended"];
//        
//        DDLogError(logString);
//    //}
//    
//    [super touchesEnded:touches withEvent:event];
//
//}

- (UIImage*)screenshot 
{
    //NOTE: This is lifted whole from the Apple documentation at
    //http://developer.apple.com/library/ios/#qa/qa1703/_index.html
    
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(void) startGestureLogging:(BOOL)recursive
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
        
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    pinch.cancelsTouchesInView = NO;
    [self addGestureRecognizer:pinch];
    
    if (recursive) {
        for (UIView *v in self.subviews) {
            [v startGestureLogging:YES];
        }
    }
    
}

-(void) tapDetected:(UITapGestureRecognizer*)recog
{
    CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
                           [self class], 
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           [recog locationInView:self].x, 
                           [recog locationInView:self].y,
                           @"recog touch"];
        
    DDLogError(logString);
    
}


-(void) pinchDetected:(UIPanGestureRecognizer*)recog
{
    CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
    
    NSString *typeString = @"";
    if (recog.state == UIGestureRecognizerStateBegan) {
        typeString = @"Pinch started";
    }
    else if (recog.state == UIGestureRecognizerStateChanged) {
        typeString = @"Pinch moved";
    }
    else if (recog.state == UIGestureRecognizerStateEnded || recog.state == UIGestureRecognizerStateCancelled) {
        typeString = @"Pinch ended";
    }
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
                           [self class], 
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           [recog locationInView:self].x, 
                           [recog locationInView:self].y,
                           typeString];
    
    DDLogError(logString);
    
}

#pragma mark Scroll logging helper methods
-(void) scrollLogHelper:(UIScrollView*)scrollView typeString:(NSString*)tString
{
    CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@,%1.0f,%1.0f\n", 
                           [self class], 
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           -1.0, 
                           -1.0,
                           tString,
                           scrollView.contentOffset.x,
                           scrollView.contentOffset.y
                           ];
    
    DDLogError(logString);

}

-(void) logScrollStarted:(UIScrollView*)scrollView
{
    [self scrollLogHelper:scrollView typeString:@"scroll started"];
}

-(void) logScrollChanged:(UIScrollView*)scrollView
{
    [self scrollLogHelper:scrollView typeString:@"scroll moved"];

}

-(void) logScrollEnded:(UIScrollView*)scrollView
{
    [self scrollLogHelper:scrollView typeString:@"scroll ended"];

}

//#pragma mark - Logging setup (configure on/off variable via associate references, etc.)
//-(BOOL) touchLoggingEnabled
//{
//    NSNumber *loggingVal = (NSNumber*) objc_getAssociatedObject(self, TouchLoggingKey);
//    return [loggingVal boolValue];
//}
//
//-(void) setTouchLoggingEnabled:(BOOL)enabled
//{
//    NSNumber *loggingVal = [NSNumber numberWithBool:enabled];
//    objc_setAssociatedObject(self, TouchLoggingKey, loggingVal, OBJC_ASSOCIATION_RETAIN);
//}


@end
