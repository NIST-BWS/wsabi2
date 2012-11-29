//
//  UIView+BWSLogging.h
//

#import <UIKit/UIKit.h>

/// Types of events that can be tracked by this category.
typedef enum
{
    /// Tap
    kBWSEventTypeTap,
    /// Scroll began
    kBWSEventTypeScrollBegan,
    /// Scroll ended
    kBWSEventTypeScrollEnded,
    /// Long press began
    kBWSEventTypeLongPressBegan,
    /// Long press ended
    kBWSEventTypeLongPressEnded,
    /// Pinch began
    kBWSEventTypePinchBegan,
    /// Pinch ended
    kBWSEventTypePinchEnded
} BWSEventType;

//
// Textual descrptions of BWSEventTypes
//

/// Tap
static NSString * const kBWSEventTypeTapDescription = @"tap";
/// Scroll began
static NSString * const kBWSEventTypeScrollBeganDescription = @"scrollBegin";
/// Scroll ended
static NSString * const kBWSEventTypeScrollEndedDescription = @"scrollEnd";
/// Long press began
static NSString * const kBWSEventTypeLongPressBeganDescription = @"lpBegin";
/// Long press ended
static NSString * const kBWSEventTypeLongPressEndedDescription = @"lpEnd";
/// Pinch began
static NSString * const kBWSEventTypePinchBeganDescription = @"pinchBegin";
/// Pinch ended
static NSString * const kBWSEventTypePinchEndedDescription = @"pinchEnd";
/// Unknown event
static NSString * const kBWSEventTypeUnknown = @"unknown";

/// Log information about user interaction with interface elements
@interface UIView (BWSLogging)

/// Start logging events for the specified event type.
- (void)startLoggingBWSEventType:(BWSEventType)eventType;
/// Stop logging all events.
- (void)stopLoggingBWSEvents;

/// Obtain the textual description of an event type.
+ (NSString *)stringForBWSEventType:(BWSEventType)eventType;

@end
