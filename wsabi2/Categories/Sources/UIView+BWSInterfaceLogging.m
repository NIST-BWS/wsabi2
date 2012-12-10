//
//  UIView+BWSLogging.m
//

#import "UIView+BWSInterfaceLogging.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface UIView (BWSLoggingPrivate)

//
// Recognizer callbacks
//

/// Tap recognizer callback
- (void)BWSInterfaceEventTapDetected:(UITapGestureRecognizer *)recognizer;

/// @brief
/// Obtain a string describing a tap event
/// @return
/// String in the format:
/// Item Description (Item Class), Event Type, (Local Touch Coordinate of Tap)
/// [Global Touch Coordinate of Tap], Dimensions of Tapped Object
/// (Top-Left Coordinate of Tapped Object)
- (NSString *)logBWSInterfaceEventTapAtPoint:(CGPoint)point;

@end

@implementation UIView (BWSLogging)

- (NSString *)logBWSInterfaceEventTapAtPoint:(CGPoint)point
{
    CGPoint pointInWindow = [self convertPoint:point toView:nil];
    CGRect viewInWindowRect = [[self superview] convertRect:self.frame toView:nil];
        
    return ([NSString stringWithFormat:@"********** %@ (%@), %@, (%.0f, %.0f) [%.0f, %.0f], %.0fx%.0f (%.0f, %.0f)",
                           [self accessibilityLabel],
                           [self class],
                           [UIView stringForBWSInterfaceEventType:kBWSInterfaceEventTypeTap],
                           point.x,
                           point.y,
                           pointInWindow.x,
                           pointInWindow.y,
                           self.frame.size.width,
                           self.frame.size.height,
                           viewInWindowRect.origin.x,
                           viewInWindowRect.origin.y]);
}

#pragma mark - Recognizer Callbacks

- (void)BWSInterfaceEventTapDetected:(UITapGestureRecognizer *)recognizer
{
    DDLogError([self logBWSInterfaceEventTapAtPoint:[recognizer locationInView:self]]);
}

#pragma mark - Presentation/Dismissal Logging

- (void)logActionSheetPresented:(UIActionSheet *)actionSheet
{
    NSMutableString *buttonTitles = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [actionSheet numberOfButtons]; i++) {
        [buttonTitles appendString:[actionSheet buttonTitleAtIndex:i]];
        if (i != ([actionSheet numberOfButtons] - 1))
            [buttonTitles appendString:@", "];
    }
    
    DDLogError(@"********** %@:[%@] (%@<-%@ (%@)), %@",
               [actionSheet title] != nil ? [actionSheet title] : @"<No Title>",
               buttonTitles,
               [actionSheet class],
               [self class],
               [self accessibilityLabel],
               kBWSInterfaceEventDescriptionPresented);
}

- (void)logActionSheetDismissed:(UIActionSheet *)actionSheet viaButtonAtIndex:(NSInteger)buttonIndex
{
    DDLogError(@"********** %@:[%@] (%@), %@",
               [actionSheet title] != nil ? [actionSheet title] : @"<No Title>",
               [actionSheet buttonTitleAtIndex:buttonIndex],
               [actionSheet class],
               kBWSInterfaceEventDescriptionDismissed);
}

- (void)logPopoverControllerPresented:(UIPopoverController *)popoverController
{
    DDLogError(@"********** %@[<-%@ (%@)] (%@), %@",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [self accessibilityLabel],
               [self class],
               [popoverController class],
               kBWSInterfaceEventDescriptionPresented);
}

- (void)logPopoverControllerPresented:(UIPopoverController *)popoverController viaTapAtPoint:(CGPoint)point
{
    DDLogError(@"********** %@[<-%@ (%@)] (%@), %@ (%.0f, %.0f)",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [self accessibilityLabel],
               [self class],
               [popoverController class],
               kBWSInterfaceEventDescriptionPresented,
               point.x,
               point.y);
}

- (void)logPopoverControllerDismissed:(UIPopoverController *)popoverController
{
    DDLogError(@"********** %@ (%@), %@",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [popoverController class],
               kBWSInterfaceEventDescriptionDismissed);
}

- (void)logPopoverControllerDismissed:(UIPopoverController *)popoverController viaTapAtPoint:(CGPoint)point
{
    DDLogError(@"********** %@ (%@), %@ (%.0f, %.0f)",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [popoverController class],
               kBWSInterfaceEventDescriptionDismissed,
               point.x,
               point.y);
}

- (void)logViewPresented
{
    DDLogError(@"********** %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionPresented);
}

- (void)logViewDismissed
{
    DDLogError(@"********** %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionDismissed);
}

- (void)logViewDismissedViaTapAtPoint:(CGPoint)point
{
    DDLogError(@"********** %@ (%@), %@ (%.0f, %.0f)",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionDismissed,
               point.x,
               point.y);
}

#pragma mark - Text Entry Logging

- (void)logTextEntryBegan
{
    DDLogError(@"********** %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionTextEntryBegan);
}

- (void)logTextEntryEnded
{
    DDLogError(@"********** %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionTextEntryEnded);
}

#pragma mark - Start/Stop

- (void)startLoggingBWSInterfaceEventType:(BWSInterfaceEventType)eventType
{
    UIGestureRecognizer *recognizer = nil;
    
    switch (eventType) {
        case kBWSInterfaceEventTypeTap:
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BWSInterfaceEventTapDetected:)];
            break;
        default:
            DDLogError(@"%@ logging currently unsupported", [UIView stringForBWSInterfaceEventType:eventType]);
            break;
    }
    
    if (recognizer != nil) {
        [recognizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:recognizer];
    }
}

- (void)stopLoggingBWSInterfaceEvents
{
    for (UIGestureRecognizer *recognizer in [self gestureRecognizers])
        [self removeGestureRecognizer:recognizer];
}

#pragma mark - BWSInterfaceEventType

+ (NSString *)stringForBWSInterfaceEventType:(BWSInterfaceEventType)eventType
{
    switch (eventType) {
        case kBWSInterfaceEventTypeTap:
            return (kBWSInterfaceEventTypeTapDescription);
        case kBWSInterfaceEventTypeScrollBegan:
            return (kBWSInterfaceEventTypeScrollBeganDescription);
        case kBWSInterfaceEventTypeScrollEnded:
            return (kBWSInterfaceEventTypeScrollEndedDescription);
        case kBWSInterfaceEventTypeLongPressBegan:
            return (kBWSInterfaceEventTypeLongPressBeganDescription);
        case kBWSInterfaceEventTypeLongPressEnded:
            return (kBWSInterfaceEventTypeLongPressBeganDescription);
        case kBWSInterfaceEventTypePinchBegan:
            return (kBWSInterfaceEventTypePinchBeganDescription);
        case kBWSInterfaceEventTypePinchEnded:
            return (kBWSInterfaceEventTypePinchEndedDescription);
    }
    
    return (kBWSInterfaceEventTypeUnknown);
}

@end
