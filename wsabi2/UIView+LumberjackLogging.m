//
//  UserTesting.m
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+LumberjackLogging.h"
#import <objc/runtime.h>

#define USER_TESTING_PREF @"user-testing-file"

@implementation UIView (LumberjackLogging)

@dynamic touchLoggingEnabled;
static char const * const TouchLoggingKey = "TouchLogging";

+(BOOL) startNewUserTestingFile
{    
    //This creates a new CSV-based, UTF-8
    
    //get a reference to the documents directory
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //store the new filename as a user preference, overwriting the existing entry if necessary
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'UserTestLog_'yyyy-MM-dd_HH:mm:ss'.txt'"];
    NSDate *now = [NSDate date];
    
    NSString *filename = [documentsDir stringByAppendingPathComponent:[formatter stringFromDate:now]];

    //Create the file (inserting header information), then store its path in the user preferences.
    NSError *err = nil;
    if(![@"Timestamp,Class,FrameX,FrameY,FrameW,FrameH,TouchX,TouchY,TouchType\n" writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&err])
    {
        NSLog(@"Couldn't create a new user testing log at %@, error was: %@",filename, [err description]);
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:filename forKey:USER_TESTING_PREF];
    return YES;
 }

+(void) appendUserTestingStringToCurrentLog:(NSString*)theString
{
    //Tag the string with the current time.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss zzz,"];
    NSDate *now = [NSDate date];
    NSString *timedString = [[formatter stringFromDate:now] stringByAppendingString:theString];
    
    NSData *dataToWrite = [timedString dataUsingEncoding: NSUTF8StringEncoding];

    //Get the path of the current log file
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSString *logFilePath = [defaults objectForKey:USER_TESTING_PREF];
    
    //If there is no stored file, create one.
    if (!logFilePath) {
        BOOL createSuccess = [UIView startNewUserTestingFile];
        if (!createSuccess) {
            NSLog(@"UIView::appendUserTestingStringToCurrentLog: No file to append to, and starting a new file was unsuccessful.");
            return;
        }
    }
    
    //write to it.
    NSFileHandle* outputFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    [outputFile seekToEndOfFile];
    [outputFile writeData:dataToWrite];
}

//Implement a logging listener to every touch event passed through this window

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *aTouch = [touches anyObject];
    [super touchesBegan:touches withEvent:event];

    CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
                           [self class], 
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           [aTouch locationInView:self.window].x, 
                           [aTouch locationInView:self.window].y,
                           @"touch down"];
    
    //NSLog(@"%@: Got a touch at x: %f and y:%f", [self class], [aTouch locationInView:self.window].x, [aTouch locationInView:self.window].y);
    [UIView appendUserTestingStringToCurrentLog:logString];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    [super touchesMoved:touches withEvent:event];
    
    CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
                           [self class], 
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           [aTouch locationInView:self.window].x, 
                           [aTouch locationInView:self.window].y,
                           @"touch moved"];

    //NSLog(@"%@: Got a drag at x: %f and y:%f", [self class], [aTouch locationInView:self.window].x, [aTouch locationInView:self.window].y);
    [UIView appendUserTestingStringToCurrentLog:logString];


}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    [super touchesEnded:touches withEvent:event];
    
    CGRect convertedFrame = [self convertRect:self.frame toView:nil]; //converts to window base coordinates
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%1.0f,%@\n", 
                           [self class], 
                           convertedFrame.origin.x,
                           convertedFrame.origin.y,
                           convertedFrame.size.width,
                           convertedFrame.size.height,
                           [aTouch locationInView:self.window].x, 
                           [aTouch locationInView:self.window].y,
                           @"touch ended"];
    
    [UIView appendUserTestingStringToCurrentLog:logString];    
    
}


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

#pragma mark - Logging setup (configure on/off variable via associate references, etc.)
-(BOOL) touchLoggingEnabled
{
    NSNumber *loggingVal = (NSNumber*) objc_getAssociatedObject(self, TouchLoggingKey);
    return [loggingVal boolValue];
}

-(void) setTouchLoggingEnabled:(BOOL)enabled
{
    NSNumber *loggingVal = [NSNumber numberWithBool:enabled];
    objc_setAssociatedObject(self, TouchLoggingKey, loggingVal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setObjectTag:(id)newObjectTag {
}

@end
