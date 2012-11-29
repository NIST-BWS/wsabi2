//
//  UserTesting.m
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//

#import "UIView+Logging.h"
#import <objc/runtime.h>

@implementation UIView (Logging)

static char const * const TouchLoggingKey = "TouchLogging";
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


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

-(CGPoint) dummyPoint
{
    return CGPointMake(-1,-1);
}

-(NSString*) baseLogString:(NSString*)eventType withLocalPoint:(CGPoint)localPoint withWindowPoint:(CGPoint)globalPoint
{
    CGRect convertedFrame = [self.superview convertRect:self.frame toView:nil]; //converts to window base coordinates
        
    UIViewController *vc = [self firstAvailableUIViewController];

    NSMutableString *vcIdentifier = [[NSString stringWithFormat:@"%@",[vc class]] mutableCopy];
    if(vc.title)
    {
        [vcIdentifier appendFormat:@"(\"%@\")",vc.title];
    }
    
    NSString *logString = [NSString stringWithFormat:@"%@::%@,%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f", 
                           vcIdentifier,
                           [self accessibilityLabel],
                           eventType,
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           localPoint.x, 
                           localPoint.y,
                           globalPoint.x,
                           globalPoint.y
                          ];
    
    return logString;
}

-(void) addLongPressGestureLogging:(BOOL)recursive withThreshold:(float)seconds
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
    longPress.cancelsTouchesInView = NO;
    if (seconds > 0) {
        longPress.minimumPressDuration = seconds;
    }
 
    [self addGestureRecognizer:longPress];
    
    if (recursive) {
        for (UIView *v in self.subviews) {
            if (![v isKindOfClass:[UITextField class]] && 
                ![v isKindOfClass:[UITextView class]]) {
                [v addLongPressGestureLogging:YES withThreshold:seconds];
            }
        }
    }

}

-(void) tapDetected:(UITapGestureRecognizer*)recog
{        
    NSString *resultString = [self baseLogString:@"tap" 
                                  withLocalPoint:[recog locationInView:self]
                                 withWindowPoint:[recog locationInView:nil]];

    DDLogError(resultString);
}


-(void) pinchDetected:(UIPanGestureRecognizer*)recog
{    
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
    
    NSString *resultString = [self baseLogString:typeString 
                             withLocalPoint:[recog locationInView:self]
                            withWindowPoint:[recog locationInView:nil]];
    
    DDLogError(resultString);
    
}

-(void) longPressDetected:(UILongPressGestureRecognizer*)recog
{
    NSString *typeString = @"";
    if (recog.state == UIGestureRecognizerStateBegan) {
        typeString = @"Long press started";
    }
    else if (recog.state == UIGestureRecognizerStateChanged) {
        typeString = @"Long press moved";
    }
    else if (recog.state == UIGestureRecognizerStateEnded || recog.state == UIGestureRecognizerStateCancelled) {
        typeString = @"Long press ended";
    }
    
    NSString *resultString = [self baseLogString:typeString 
                                  withLocalPoint:[recog locationInView:self]
                                 withWindowPoint:[recog locationInView:nil]];
    
    DDLogError(resultString);

}


#pragma mark Scroll logging helper methods
-(void) scrollLogHelper:(NSString*)eventType
{
    if ([self isKindOfClass:[UIScrollView class]]) {

        NSString *resultString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f",
                                  [self baseLogString:eventType 
                                      withLocalPoint:[self dummyPoint]
                                     withWindowPoint:[self dummyPoint]],
                                  ((UIScrollView*)self).contentOffset.x,
                                  ((UIScrollView*)self).contentOffset.y
                                  ];
        
        DDLogError(resultString);
    }
    else {
        DDLogError(@"Tried to log something that wasn't a scroll view as a scroll view. Ignoring.");
    }
    

}

-(void) logScrollStarted
{
    [self scrollLogHelper:@"scroll started"];
}

-(void) logScrollChanged
{
    [self scrollLogHelper:@"scroll moved"];

}

-(void) logScrollEnded
{
    [self scrollLogHelper:@"scroll ended"];

}

#pragma mark Text Field & Text View logging
-(void) logTextFieldStarted:(NSIndexPath*)position
{
    NSMutableString *resultString = [[self baseLogString:@"text field started editing" 
                                          withLocalPoint:[self dummyPoint]
                                         withWindowPoint:[self dummyPoint]] mutableCopy];
    
    if (position) {
        [resultString appendFormat:@",s%d,r%d",position.section, position.row];
    }
    DDLogError(resultString);
}

-(void) logTextFieldEnded:(NSIndexPath*)position
{
    NSMutableString *resultString = [[self baseLogString:@"text field finished editing" 
                                    withLocalPoint:[self dummyPoint]
                                  withWindowPoint:[self dummyPoint]] mutableCopy];
    
    if (position) {
        [resultString appendFormat:@",s%d,r%d",position.section, position.row];
    }
    DDLogError(resultString);
}

-(void) logTextViewStarted:(NSIndexPath*)position
{
    NSMutableString *resultString = [[self baseLogString:@"text view started editing" 
                                          withLocalPoint:[self dummyPoint]
                                         withWindowPoint:[self dummyPoint]] mutableCopy];
    
    if (position) {
        [resultString appendFormat:@",s%d,r%d",position.section, position.row];
    }
    DDLogError(resultString);
}

-(void) logTextViewEnded:(NSIndexPath*)position
{
    NSMutableString *resultString = [[self baseLogString:@"text view finished editing" 
                                          withLocalPoint:[self dummyPoint]
                                         withWindowPoint:[self dummyPoint]] mutableCopy];
    
    if (position) {
        [resultString appendFormat:@",s%d,r%d",position.section, position.row];
    }
    DDLogError(resultString);
}

//
// FIXME: There only needs to be one method (-logEvent:) and many constants
//

#pragma mark Popover logging
-(void) logPopoverShownFrom:(UIView*)source
{
//    //FIXME: Make this more useful!
//    NSMutableString *resultString = [@"Displaying a popover" mutableCopy];
//    if (source) {
//        [resultString appendFormat:@" from %@",[source class]];
//    }
    
    //FIXME: Should we use the source info for something, or does it always
    //duplicate the calling object?
    NSString *resultString;
//    if (source) {
//        resultString = [self baseLogString:@"popover opened" 
//                            withLocalPoint:[self dummyPoint]
//                           withWindowPoint:[self dummyPoint]];
//
//    }
//    else
//    {
        resultString = [self baseLogString:@"popover opened" 
                            withLocalPoint:[self dummyPoint]
                           withWindowPoint:[self dummyPoint]];
//    }
    
    DDLogError(resultString);
}

-(void) logPopoverHidden
{
    NSString *resultString = [self baseLogString:@"popover closed" 
                        withLocalPoint:[self dummyPoint]
                       withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);
}

#pragma mark Action Sheet logging
-(void) logActionSheetShown:(BOOL)shownInPopover
{
    NSString *sheetType = shownInPopover ? @"action sheet opened in popover" : @"action sheet opened";
    NSString *resultString = [self baseLogString:sheetType 
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);

}

-(void) logActionSheetHidden
{
    NSString *resultString = [self baseLogString:@"action sheet closed" 
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);
}

#pragma mark System event logging

-(void) logEnterBackground
{
    NSString *resultString = [self baseLogString:@"app entered background" 
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);
}

-(void) logEnterForeground
{
    NSString *resultString = [self baseLogString:@"app entered foreground" 
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);
}

-(void) logViewPresented
{
    NSString *resultString = [self baseLogString:@"view presented"
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);
}

-(void) logViewDismissed
{
    NSString *resultString = [self baseLogString:@"view dismissed"
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:[self dummyPoint]];
    DDLogError(resultString);
}

-(void) logViewDismissedViaTapAtPoint:(CGPoint)point
{
    NSString *resultString = [self baseLogString:@"view dismissed via tap"
                                  withLocalPoint:[self dummyPoint]
                                 withWindowPoint:point];
    DDLogError(resultString);
}

@end
