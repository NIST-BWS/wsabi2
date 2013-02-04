// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.
#import "DDLog.h"

#import "UIView+BWSInterfaceLogging.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface UIView (BWSLoggingPrivate)

//
// Recognizer callbacks
//

/// Tap recognizer callback
- (void)BWSInterfaceEventTapDetected:(UITapGestureRecognizer *)recognizer;
/// @brief
/// Scrolling recognizer callback
/// @details
/// Logs a generic InterfaceEvent and appends PPS:(h,v) representing the
/// velocity of the scroll, measured in points per second in the horizontal and
/// vertical directions.
- (void)BWSInterfaceEventScrollDetected:(UIPanGestureRecognizer *)recognizer;
/// LongPress recognizer callback
- (void)BWSInterfaceEventLongPressDetected:(UILongPressGestureRecognizer *)recognizer;
/// @brief
/// Pinch recognizer callback
/// @details
/// Logs a generic InterfaceEvent, but all coordinates that are part of the
/// pinch are logged ((local) & (coords)), [(global) & (coords)]
- (void)BWSInterfaceEventPinchDetected:(UIPinchGestureRecognizer *)recognizer;


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
    
    return ([NSString stringWithFormat:@"<TL>: %@ (%@), %@, (%.0f, %.0f) [%.0f, %.0f], %.0fx%.0f (%.0f, %.0f)",
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

+ (BWSInterfaceEventState)interfaceEventStateForGestureRecognizerState:(UIGestureRecognizerState)state
{
    // Toll-free bridge for some types
    switch (state) {
        case UIGestureRecognizerStateBegan:
            return (kBWSInterfaceEventStateBegan);
        case UIGestureRecognizerStateEnded:
            return (kBWSInterfaceEventStateEnded);
        default:
            return (kBWSInterfaceEventStateUnknown);
    }
}
#pragma mark - Recognizer Callbacks

- (void)BWSInterfaceEventTapDetected:(UITapGestureRecognizer *)recognizer
{
    DDLogError(@"%@", [self logBWSInterfaceEventTapAtPoint:[recognizer locationInView:self]]);
    
    // XXX: For text entry fields, our tap recognizer overrides Apple's for 
    // becoming the first responder.
    if ([self isKindOfClass:[UITextView class]] || [self isKindOfClass:[UITextField class]])
        [self becomeFirstResponder];
}

- (void)BWSInterfaceEventScrollDetected:(UIPanGestureRecognizer *)recognizer
{
    NSMutableString *logString = nil;
    
    // Toll-free bridge UIGestureRecognizerEventState to BWSInterfaceEventState
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            // FALLTHROUGH
        case UIGestureRecognizerStateEnded:
            logString = [[NSMutableString alloc] initWithString:[self logGenericBWSInterfaceEvent:kBWSInterfaceEventTypeScroll atPoint:[recognizer locationInView:self] withState:[UIView interfaceEventStateForGestureRecognizerState:[recognizer state]]]];
            CGPoint velocity = [recognizer velocityInView:self];
            [logString appendFormat:@" PPS:(%.0f, %.0f)", velocity.x, velocity.y];
            break;
        default:
            // Not interested
            break;
    }
    
    if (logString != nil)
        DDLogError(@"%@", logString);
}

- (void)BWSInterfaceEventLongPressDetected:(UILongPressGestureRecognizer *)recognizer
{
    // Toll-free bridge UIGestureRecognizerEventState to BWSInterfaceEventState
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            // FALLTHROUGH
        case UIGestureRecognizerStateEnded:
            DDLogError(@"%@", [self logGenericBWSInterfaceEvent:kBWSInterfaceEventTypeLongPress atPoint:[recognizer locationInView:self] withState:[UIView interfaceEventStateForGestureRecognizerState:[recognizer state]]]);
            break;
        default:
            // Not interested
            break;
    }
}

- (void)BWSInterfaceEventPinchDetected:(UIPinchGestureRecognizer *)recognizer
{
    // Toll-free bridge UIGestureRecognizerEventState to BWSInterfaceEventState
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            // FALLTHROUGH
        case UIGestureRecognizerStateEnded: {
            NSMutableString *localCoordinates = [[NSMutableString alloc] initWithString:@"("];
            NSMutableString *globalCoordinates = [[NSMutableString alloc] initWithString:@"["];
            CGPoint point;
            for (NSUInteger i = 0; i < recognizer.numberOfTouches; i++) {
                point = [recognizer locationOfTouch:i inView:self];
                [localCoordinates appendFormat:@"(%.0f, %.0f)", point.x, point.y];
                point = [recognizer locationOfTouch:0 inView:nil];
                [globalCoordinates appendFormat:@"(%.0f, %.0f)", point.x, point.y];
                
                if (i != (recognizer.numberOfTouches - 1)) {
                    [localCoordinates appendString:@" & "];
                    [globalCoordinates appendString:@" & "];
                }
            }
            [localCoordinates appendString:@")"];
            [globalCoordinates appendString:@"]"];
            
            CGRect viewInWindowRect = [[self superview] convertRect:self.frame toView:nil];
            
            DDLogError (@"%@", [NSString stringWithFormat:@"<TL>: %@ (%@), %@, %@ %@, %.0fx%.0f (%.0f, %.0f)",
                     [self accessibilityLabel],
                     [self class],
                     [UIView stringForBWSInterfaceEventType:kBWSInterfaceEventTypePinch withState:[UIView interfaceEventStateForGestureRecognizerState:recognizer.state]],
                     localCoordinates,
                     globalCoordinates,
                     self.frame.size.width,
                     self.frame.size.height,
                     viewInWindowRect.origin.x,
                     viewInWindowRect.origin.y]);
            break;
        }
        default:
            // Not interested
            break;
    }
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
    
    DDLogError(@"<TL>: %@:[%@] (%@<-%@ (%@)), %@",
               [actionSheet title] != nil ? [actionSheet title] : @"<No Title>",
               buttonTitles,
               [actionSheet class],
               [self class],
               [self accessibilityLabel],
               kBWSInterfaceEventDescriptionPresented);
}

- (void)logActionSheetDismissed:(UIActionSheet *)actionSheet viaButtonAtIndex:(NSInteger)buttonIndex
{
    DDLogError(@"<TL>: %@:[%@] (%@), %@",
               [actionSheet title] != nil ? [actionSheet title] : @"<No Title>",
               [actionSheet buttonTitleAtIndex:buttonIndex],
               [actionSheet class],
               kBWSInterfaceEventDescriptionDismissed);
}

- (void)logPopoverControllerPresented:(UIPopoverController *)popoverController
{
    DDLogError(@"<TL>: %@[<-%@ (%@)] (%@), %@",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [self accessibilityLabel],
               [self class],
               [popoverController class],
               kBWSInterfaceEventDescriptionPresented);
}

- (void)logPopoverControllerPresented:(UIPopoverController *)popoverController viaTapAtPoint:(CGPoint)point
{
    DDLogError(@"<TL>: %@[<-%@ (%@)] (%@), %@ (%.0f, %.0f)",
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
    DDLogError(@"<TL>: %@ (%@), %@",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [popoverController class],
               kBWSInterfaceEventDescriptionDismissed);
}

- (void)logPopoverControllerDismissed:(UIPopoverController *)popoverController viaTapAtPoint:(CGPoint)point
{
    DDLogError(@"<TL>: %@ (%@), %@ (%.0f, %.0f)",
               [[[popoverController contentViewController] view] accessibilityLabel],
               [popoverController class],
               kBWSInterfaceEventDescriptionDismissed,
               point.x,
               point.y);
}

- (void)logViewPresented
{
    DDLogError(@"<TL>: %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionPresented);
}

- (void)logViewDismissed
{
    DDLogError(@"<TL>: %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionDismissed);
}

- (void)logViewDismissedViaTapAtPoint:(CGPoint)point
{
    DDLogError(@"<TL>: %@ (%@), %@ (%.0f, %.0f)",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionDismissed,
               point.x,
               point.y);
}

#pragma mark - Text Entry Logging

- (void)logTextEntryBegan
{
    DDLogError(@"<TL>: %@ (%@), %@",
               [self accessibilityLabel],
               [self class],
               kBWSInterfaceEventDescriptionTextEntryBegan);
}

- (void)logTextEntryEnded
{
    DDLogError(@"<TL>: %@ (%@), %@",
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
        case kBWSInterfaceEventTypeLongPress:
            recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(BWSInterfaceEventLongPressDetected:)];
            break;
        case kBWSInterfaceEventTypePinch:
            recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(BWSInterfaceEventPinchDetected:)];
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
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return (YES);
    return (NO);
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
