//
//  UIView+BWSLogging.m
//

#import "UIView+BWSLogging.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface UIView (BWSLoggingPrivate)

//
// Recognizer callbacks
//

/// Tap recognizer callback
- (void)BWSEventTapDetected:(UITapGestureRecognizer *)recognizer;

/// @brief
/// Obtain a string describing a tap event
/// @return
/// String in the format:
/// Item Description (Item Class), Event Type, (Local Touch Coordinate of Tap)
/// [Global Touch Coordinate of Tap], Dimensions of Tapped Object
/// (Top-Left Coordinate of Tapped Object)
- (NSString *)logBWSEventTapAtPoint:(CGPoint)point;

@end

@implementation UIView (BWSLogging)

- (NSString *)logBWSEventTapAtPoint:(CGPoint)point
{
    CGPoint pointInWindow = [self convertPoint:point toView:nil];
    CGRect viewInWindowRect = [[self superview] convertRect:self.frame toView:nil];
        
    return ([NSString stringWithFormat:@"********** %@ (%@), %@, (%.0f, %.0f) [%.0f, %.0f], %.0fx%.0f (%.0f, %.0f)",
                           [self accessibilityLabel],
                           [self class],
                           [UIView stringForBWSEventType:kBWSEventTypeTap],
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

- (void)BWSEventTapDetected:(UITapGestureRecognizer *)recognizer
{
    DDLogError([self logBWSEventTapAtPoint:[recognizer locationInView:self]]);
}

#pragma mark - Start/Stop

- (void)startLoggingBWSEventType:(BWSEventType)eventType
{
    UIGestureRecognizer *recognizer = nil;
    
    switch (eventType) {
        case kBWSEventTypeTap:
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BWSEventTapDetected:)];
            break;
        default:
            DDLogError(@"%@ logging currently unsupported", [UIView stringForBWSEventType:eventType]);
            break;
    }
    
    if (recognizer != nil) {
        [recognizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:recognizer];
    }
}

- (void)stopLoggingBWSEvents
{
    for (UIGestureRecognizer *recognizer in [self gestureRecognizers])
        [self removeGestureRecognizer:recognizer];
}

#pragma mark - BWSEventType

+ (NSString *)stringForBWSEventType:(BWSEventType)eventType
{
    switch (eventType) {
        case kBWSEventTypeTap:
            return (kBWSEventTypeTapDescription);
        case kBWSEventTypeScrollBegan:
            return (kBWSEventTypeScrollBeganDescription);
        case kBWSEventTypeScrollEnded:
            return (kBWSEventTypeScrollEndedDescription);
        case kBWSEventTypeLongPressBegan:
            return (kBWSEventTypeLongPressBeganDescription);
        case kBWSEventTypeLongPressEnded:
            return (kBWSEventTypeLongPressBeganDescription);
        case kBWSEventTypePinchBegan:
            return (kBWSEventTypePinchBeganDescription);
        case kBWSEventTypePinchEnded:
            return (kBWSEventTypePinchEndedDescription);
    }
    
    return (kBWSEventTypeUnknown);
}

@end
