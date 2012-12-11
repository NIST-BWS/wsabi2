//
//  UIView+BWSLogging.h
//

#import <UIKit/UIKit.h>

/// Types of interface events that can be tracked by this category.
typedef enum
{
    /// Tap
    kBWSInterfaceEventTypeTap,
    /// Scroll
    kBWSInterfaceEventTypeScroll,
    /// Long press
    kBWSInterfaceEventTypeLongPress,
    /// Pinch
    kBWSInterfaceEventTypePinch,
} BWSInterfaceEventType;

/// State of interface events
typedef enum
{
    /// Began
    kBWSInterfaceEventStateBegan = UIGestureRecognizerStateBegan,
    /// Ended
    kBWSInterfaceEventStateEnded = UIGestureRecognizerStateEnded,
    /// Stateless
    kBWSInterfaceEventStateStateless,
    /// Unknown
    kBWSInterfaceEventStateUnknown
} BWSInterfaceEventState;

//
// Textual descrptions of BWSInterfaceEventTypes
//

/// Tap
static NSString * const kBWSInterfaceEventTypeTapDescription = @"tap";
/// Scroll (generic)
static NSString * const kBWSInterfaceEventTypeScrollDescription = @"scroll";
/// Scroll began
static NSString * const kBWSInterfaceEventTypeScrollBeganDescription = @"scrollBegin";
/// Scroll ended
static NSString * const kBWSInterfaceEventTypeScrollEndedDescription = @"scrollEnd";
/// Long press (generic)
static NSString * const kBWSInterfaceEventTypeLongPressDescription = @"lp";
/// Long press began
static NSString * const kBWSInterfaceEventTypeLongPressBeganDescription = @"lpBegin";
/// Long press ended
static NSString * const kBWSInterfaceEventTypeLongPressEndedDescription = @"lpEnd";
/// Pinch (generic)
static NSString * const kBWSInterfaceEventTypePinchDescription = @"pinch";
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
/// Text entry began
static NSString * const kBWSInterfaceEventDescriptionTextEntryBegan = @"textEntryBegin";
/// Text entry ended
static NSString * const kBWSInterfaceEventDescriptionTextEntryEnded = @"textEntryEnd";


/// Log information about user interaction with interface elements
@interface UIView (BWSLogging) <UIGestureRecognizerDelegate>

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

/// PopoverController presented
- (void)logPopoverControllerPresented:(UIPopoverController *)popoverController;
/// PopoverController presented and point is known
- (void)logPopoverControllerPresented:(UIPopoverController *)popoverController viaTapAtPoint:(CGPoint)point;
/// PopoverController dismissed
- (void)logPopoverControllerDismissed:(UIPopoverController *)popoverController;
/// PopoverController dismissed and point is known
- (void)logPopoverControllerDismissed:(UIPopoverController *)popoverController viaTapAtPoint:(CGPoint)point;


/// Generic view presented
-(void) logViewPresented;
/// Generic view dismissed
-(void) logViewDismissed;
/// Generic view dismissed via tap
-(void) logViewDismissedViaTapAtPoint:(CGPoint)point;

/// Text field became first responder
- (void)logTextEntryBegan;
/// Text field resigned first responder
- (void)logTextEntryEnded;


/// Obtain the textual description of an event type.
+ (NSString *)stringForBWSInterfaceEventType:(BWSInterfaceEventType)eventType;
/// Obtain the textual description of an event type during a specific state
+ (NSString *)stringForBWSInterfaceEventType:(BWSInterfaceEventType)eventType withState:(BWSInterfaceEventState)state;


@end
