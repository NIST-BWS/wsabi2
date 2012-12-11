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
/// Scrolling recognizer callback
- (void)BWSInterfaceEventScrollDetected:(UIPanGestureRecognizer *)recognizer;

/// @brief
/// Obtain a string describing an event
/// @return
/// String in the format:
/// Item Description (Item Class), Event Type, (Local Touch Coordinate of Tap)
/// [Global Touch Coordinate of Tap], Dimensions of Tapped Object
/// (Top-Left Coordinate of Tapped Object)
- (NSString *)logGenericBWSInterfaceEvent:(BWSInterfaceEventType)interfaceEvent atPoint:(CGPoint)point;
/// Obtain a string describing an event at a particular state
- (NSString *)logGenericBWSInterfaceEvent:(BWSInterfaceEventType)interfaceEvent atPoint:(CGPoint)point withState:(BWSInterfaceEventState)state;

/// Obtain a string describing a tap event
- (NSString *)logBWSInterfaceEventTapAtPoint:(CGPoint)point;

@end

@implementation UIView (BWSLogging)

#pragma mark - BWS Interface Event Logging

- (NSString *)logGenericBWSInterfaceEvent:(BWSInterfaceEventType)interfaceEvent atPoint:(CGPoint)point
{
    return ([self logGenericBWSInterfaceEvent:interfaceEvent atPoint:point withState:kBWSInterfaceEventStateStateless]);
}

- (NSString *)logGenericBWSInterfaceEvent:(BWSInterfaceEventType)interfaceEvent atPoint:(CGPoint)point withState:(BWSInterfaceEventState)state
{
    CGPoint pointInWindow = [self convertPoint:point toView:nil];
    CGRect viewInWindowRect = [[self superview] convertRect:self.frame toView:nil];
    
    return ([NSString stringWithFormat:@"********** %@ (%@), %@, (%.0f, %.0f) [%.0f, %.0f], %.0fx%.0f (%.0f, %.0f)",
             [self accessibilityLabel],
             [self class],
             [UIView stringForBWSInterfaceEventType:interfaceEvent withState:state],
             point.x,
             point.y,
             pointInWindow.x,
             pointInWindow.y,
             self.frame.size.width,
             self.frame.size.height,
             viewInWindowRect.origin.x,
             viewInWindowRect.origin.y]);
}

- (NSString *)logBWSInterfaceEventTapAtPoint:(CGPoint)point
{
    return ([self logGenericBWSInterfaceEvent:kBWSInterfaceEventTypeTap atPoint:point]);
}

#pragma mark - Recognizer Callbacks

- (void)BWSInterfaceEventTapDetected:(UITapGestureRecognizer *)recognizer
{
    DDLogError([self logBWSInterfaceEventTapAtPoint:[recognizer locationInView:self]]);
}

- (void)BWSInterfaceEventScrollDetected:(UIPanGestureRecognizer *)recognizer
{
    NSMutableString *logString = nil;
    
    // Toll-free bridge UIGestureRecognizerEventState to BWSInterfaceEventState
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            // FALLTHROUGH
        case UIGestureRecognizerStateEnded:
            logString = [[NSMutableString alloc] initWithString:[self logGenericBWSInterfaceEvent:kBWSInterfaceEventTypeScroll atPoint:[recognizer locationInView:self] withState:[recognizer state]]];
            CGPoint velocity = [recognizer velocityInView:self];
            [logString appendFormat:@" PPS:(%.0f, %.0f)", velocity.x, velocity.y];
            break;
        default:
            // Not interested
            break;
    }
    
    if (logString != nil)
        DDLogError(logString);
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
        case kBWSInterfaceEventTypeScroll:
            recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(BWSInterfaceEventScrollDetected:)];
            break;
        default:
            DDLogError(@"%@ logging currently unsupported", [UIView stringForBWSInterfaceEventType:eventType]);
            break;
    }
    
    if (recognizer != nil) {
        [recognizer setCancelsTouchesInView:NO];
        [recognizer setDelaysTouchesBegan:NO];
        [recognizer setDelaysTouchesEnded:NO];
        [self addGestureRecognizer:recognizer];
    }
}

// Needed to prevent PanGestureRecognizer from hoarding all gestures,
// even if cancelTouchesInView is set.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (YES);
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
        case kBWSInterfaceEventTypeScroll:
            return (kBWSInterfaceEventTypeScrollDescription);
        case kBWSInterfaceEventTypeLongPress:
            return (kBWSInterfaceEventTypeLongPressDescription);
        case kBWSInterfaceEventTypePinch:
            return (kBWSInterfaceEventTypePinchDescription);
    }
    
    return (kBWSInterfaceEventTypeUnknown);
}

+ (NSString *)stringForBWSInterfaceEventType:(BWSInterfaceEventType)eventType withState:(BWSInterfaceEventState)state
{
    switch (state) {
        case kBWSInterfaceEventStateBegan:
            switch (eventType) {
                case kBWSInterfaceEventTypeScroll:
                    return (kBWSInterfaceEventTypeScrollBeganDescription);
                case kBWSInterfaceEventTypePinch:
                    return (kBWSInterfaceEventTypePinchBeganDescription);
                case kBWSInterfaceEventTypeLongPress:
                    return (kBWSInterfaceEventTypeLongPressBeganDescription);
                default:
                    return (kBWSInterfaceEventTypeUnknown);
            }
            break;
        case kBWSInterfaceEventStateEnded:
            switch (eventType) {
                case kBWSInterfaceEventTypeScroll:
                    return (kBWSInterfaceEventTypeScrollEndedDescription);
                case kBWSInterfaceEventTypePinch:
                    return (kBWSInterfaceEventTypePinchEndedDescription);
                case kBWSInterfaceEventTypeLongPress:
                    return (kBWSInterfaceEventTypeLongPressEndedDescription);
                default:
                    return (kBWSInterfaceEventTypeUnknown);
            }
            break;
        case kBWSInterfaceEventStateStateless:
            return ([self stringForBWSInterfaceEventType:eventType]);
        case kBWSInterfaceEventStateUnknown:
            // FALLTHROUGH
        default:
            return (kBWSInterfaceEventTypeUnknown);
    }
}

@end
