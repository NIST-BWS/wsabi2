//
//  constants.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef wsabi2_constants_h
#define wsabi2_constants_h

#define kItemCellSize 114
#define kItemCellCornerRadius 18
#define kItemCellSpacing 10

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

#define kDictKeyTargetItem @"targetItem"
#define kDictKeySourceID @"sourceObjectID"
#define kDictKeyStartFromDevice @"startWalkthroughFromDeviceSelection"

#define kStringDelimiter @"|"

#define kLocalCameraURLPrefix @"cam://"

//Modality types
typedef enum {
	kModalityFace = 0,
    kModalityIris,
	kModalityFinger,
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


#endif
