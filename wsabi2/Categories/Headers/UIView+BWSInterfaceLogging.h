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

//
// Descriptions of other interface events
//

/// View appeared
static NSString * const kBWSInterfaceEventDescriptionPresented = @"presented";
/// View disappeared
static NSString * const kBWSInterfaceEventDescriptionDismissed = @"dismissed";

/// Log information about user interaction with interface elements
@interface UIView (BWSLogging)

/// Start logging events for the specified event type.
- (void)startLoggingBWSInterfaceEventType:(BWSInterfaceEventType)eventType;
/// Stop logging all events.
- (void)stopLoggingBWSInterfaceEvents;

/// ActionSheet presented
- (void)logActionSheetPresented:(UIActionSheet *)actionSheet;
/// ActionSheet dismissed by tapping a button
/// @note
/// On iPad, tapping outside of an ActionSheet within a Popover is reported
/// the same as tapping the invisible "Cancel" button.
- (void)logActionSheetDismissed:(UIActionSheet *)actionSheet viaButtonAtIndex:(NSInteger)buttonIndex;

/// Obtain the textual description of an event type.
+ (NSString *)stringForBWSInterfaceEventType:(BWSInterfaceEventType)eventType;

@end
