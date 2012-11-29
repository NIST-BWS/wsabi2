//
//  UIView+BWSLogging.h
//

#import <UIKit/UIKit.h>

/// Types of interface events that can be tracked by this category.
typedef enum
{
    /// Tap
    kBWSInterfaceEventTypeTap,
    /// Scroll began
    kBWSInterfaceEventTypeScrollBegan,
    /// Scroll ended
    kBWSInterfaceEventTypeScrollEnded,
    /// Long press began
    kBWSInterfaceEventTypeLongPressBegan,
    /// Long press ended
    kBWSInterfaceEventTypeLongPressEnded,
    /// Pinch began
    kBWSInterfaceEventTypePinchBegan,
    /// Pinch ended
    kBWSInterfaceEventTypePinchEnded
} BWSInterfaceEventType;

//
// Textual descrptions of BWSInterfaceEventTypes
//

/// Tap
static NSString * const kBWSInterfaceEventTypeTapDescription = @"tap";
/// Scroll began
static NSString * const kBWSInterfaceEventTypeScrollBeganDescription = @"scrollBegin";
/// Scroll ended
static NSString * const kBWSInterfaceEventTypeScrollEndedDescription = @"scrollEnd";
/// Long press began
static NSString * const kBWSInterfaceEventTypeLongPressBeganDescription = @"lpBegin";
/// Long press ended
static NSString * const kBWSInterfaceEventTypeLongPressEndedDescription = @"lpEnd";
/// Pinch began
static NSString * const kBWSInterfaceEventTypePinchBeganDescription = @"pinchBegin";
/// Pinch ended
static NSString * const kBWSInterfaceEventTypePinchEndedDescription = @"pinchEnd";
/// Unknown event
static NSString * const kBWSInterfaceEventTypeUnknown = @"unknown";

/// Log information about user interaction with interface elements
@interface UIView (BWSLogging)

/// Start logging events for the specified event type.
- (void)startLoggingBWSInterfaceEventType:(BWSInterfaceEventType)eventType;
/// Stop logging all events.
- (void)stopLoggingBWSInterfaceEvents;

/// Obtain the textual description of an event type.
+ (NSString *)stringForBWSInterfaceEventType:(BWSInterfaceEventType)eventType;

@end
