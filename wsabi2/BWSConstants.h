// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#ifndef wsabi2_constants_h
#define wsabi2_constants_h

#define kItemCellSize 114
#define kItemCellSizeVerticalAddition 28
#define kItemCellCornerRadius 18
#define kItemCellSpacing 13

#define kMaxImageSize 1024

#define kFastFadeAnimationDuration 0.1
#define kMediumFadeAnimationDuration 0.3
#define kSlowFadeAnimationDuration 0.6
#define kFlipAnimationDuration 0.4

#define kTableViewContentsAnimationDuration 0.2

#define kShowWalkthroughNotification @"showWalkthrough"
#define kCompleteWalkthroughNotification @"completeWalkthrough"
#define kCancelWalkthroughNotification @"cancelWalkthrough"

#define kStartCaptureNotification @"startCapture"
#define kStopCaptureNotification @"stopCapture"

#define kChangedWSCDItemNotification @"changedWSCDItem"
#define kShowCapturePopoverNotification @"showCapturePopover"

#define kDictKeySourceLink @"sourceLink"
#define kDictKeyTargetItem @"targetItem"
#define kDictKeyDeviceID @"deviceID"
static NSString * const kDictKeyOperation = @"opType";
#define kDictKeySequenceType @"sequenceType"
#define kDictKeyCurrentResult @"result"
#define kDictKeyMessage @"message"
#define kDictKeyStartFromDevice @"startWalkthroughFromDeviceSelection"
/// Key for the submodality section of the device configuration walkthrough
static NSString * const kDictKeyStartFromSubmodality = @"startWalkthroughFromSubmodality";

#define kStringDelimiter @"|"

#define kLocalCameraURLPrefix @"cam://"

//Modality types
typedef enum {
    kModalityFinger = 0,
	kModalityFace,
    kModalityIris,
    kModalityEar,
    kModalityVein,
    kModalityRetina,
    kModalityFoot,
	kModalityOther,
    kModality_COUNT
} WSSensorModalityType;

//Capture types
typedef enum {
    kCaptureTypeNotSet = 0,
    
    //Finger
	kCaptureTypeRightThumbRolled,
	kCaptureTypeRightIndexRolled,
	kCaptureTypeRightMiddleRolled,
	kCaptureTypeRightRingRolled,
	kCaptureTypeRightLittleRolled,
	
    kCaptureTypeRightThumbFlat,
	kCaptureTypeRightIndexFlat,
	kCaptureTypeRightMiddleFlat,
	kCaptureTypeRightRingFlat,
	kCaptureTypeRightLittleFlat,
    
	kCaptureTypeLeftThumbRolled,
	kCaptureTypeLeftIndexRolled,
	kCaptureTypeLeftMiddleRolled,
	kCaptureTypeLeftRingRolled,
	kCaptureTypeLeftLittleRolled,
    
    kCaptureTypeLeftThumbFlat,
	kCaptureTypeLeftIndexFlat,
	kCaptureTypeLeftMiddleFlat,
	kCaptureTypeLeftRingFlat,
	kCaptureTypeLeftLittleFlat,
	
	kCaptureTypeLeftSlap,
	kCaptureTypeRightSlap,
    kCaptureTypeThumbsSlap,
    
    //Iris
	kCaptureTypeLeftIris,
	kCaptureTypeRightIris, 
	kCaptureTypeBothIrises, 
    
    //Face
    kCaptureTypeFace2d,
    kCaptureTypeFace3d,
    
    //Ear
    kCaptureTypeLeftEar,
	kCaptureTypeRightEar, 
	kCaptureTypeBothEars, 
    
    //Vein
    kCaptureTypeLeftVein,
	kCaptureTypeRightVein, 
	kCaptureTypePalm, 
    kCaptureTypeBackOfHand,
    kCaptureTypeWrist,
    
    //Retina
    kCaptureTypeLeftRetina,
    kCaptureTypeRightRetina,
    kCaptureTypeBothRetinas,
    
    //Foot
    kCaptureTypeLeftFoot,
    kCaptureTypeRightFoot,
    kCaptureTypeBothFeet,
    
    //Single items
    kCaptureTypeScent,
    kCaptureTypeDNA,
    kCaptureTypeHandGeometry,
    kCaptureTypeVoice,
    kCaptureTypeGait,
    kCaptureTypeKeystroke,
    kCaptureTypeLipMovement,
    kCaptureTypeSignatureSign,
    
    kCaptureType_COUNT
} WSSensorCaptureType;

//Annotation types -- this is defined in section 19.1.18 of ANSI/NIST-ITL 1-2007
typedef enum {
    kAnnotationNone = 0,
    kAnnotationUnprintable,
    kAnnotationAmputated,
    kAnnotation_COUNT
} WSAnnotationType;

//Possible capture states for the capture UI
typedef enum {
	WSCaptureButtonStateInactive = 0,
    WSCaptureButtonStateCapture,
    WSCaptureButtonStateStop,
    WSCaptureButtonStateWarning,
    WSCaptureButtonStateWaiting,
    WSCaptureButtonStateWaitingRestartCapture,
    WSCaptureButtonStateWaiting_COUNT
} WSCaptureButtonState;

#pragma mark - Settings

/// Key for showing/hiding the advanced options button
static NSString * const kSettingsAdvancedOptionsEnabled = @"advancedOptionsEnabled";
/// Key for enabling/disabling auto-cancel of captures when capure card closed
static NSString * kSettingsCancelCaptureOnDismiss = @"cancelCaptureOnDismiss";

/// Key for enabling/disabling touch logging
static NSString * const kSettingsTouchLoggingEnabled = @"touchLoggingEnabled";
/// Default value for touch logging
static const BOOL kSettingsTouchLoggingEnabledDefault = YES;
/// Key for enabling/disabling motion logging
static NSString * const kSettingsMotionLoggingEnabled = @"motionLoggingEnabled";
/// Default value for motion logging
static const BOOL kSettingsMotionLoggingEnabledDefault = YES;
/// Key for enabling/disabling network logging
static NSString * const kSettingsNetworkLoggingEnabled = @"networkLoggingEnabled";
/// Default value for network logging
static const BOOL kSettingsNetworkLoggingEnabledDefault = YES;
/// Key for showing/hiding logging panel
static NSString * const kSettingsLoggingPanelEnabled = @"loggingPanelEnabled";
/// Default value for showing the logging panel
static const BOOL kSettingsLoggingPanelEnabledDefault = NO;
/// Key for enabling/disabling device debug logging
static NSString * const kSettingsDeviceLoggingEnabled = @"deviceLoggingEnabled";
/// Default value for device debug logging
static const BOOL kSettingsDeviceLoggingEnabledDefault = YES;
/// Key for enabling/disabling generic verbose logging
static NSString * const kSettingsVerboseLoggingEnabled = @"verboseLoggingEnabled";
/// Default value for generic verbose  logging
static const BOOL kSettingsVerboseLoggingEnabledDefault = YES;


#pragma mark - CoreData

/// Item entity
static NSString * const kBWSEntityItem = @"BWSCDItem";
/// Person entity
static NSString * const kBWSEntityPerson = @"BWSCDPerson";
/// Device definition entity
static NSString * const kBWSEntityDeviceDefinition = @"BWSCDDeviceDefinition";

#endif
