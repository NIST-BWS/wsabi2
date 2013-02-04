//
//  WSBDModalityMap.m
//  Wsabi
//
//  Created by Matt Aronoff on 2/10/11.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "BWSModalityMap.h"


@implementation BWSModalityMap


+(NSString*) stringForCaptureType:(WSSensorCaptureType)captureType
{

    switch (captureType) {
        case kCaptureTypeNotSet:
            return @"Capture Type Not Set";
            break;
            
        //Finger
        case kCaptureTypeRightThumbRolled:
            return @"Right Thumb (Rolled)";
            break;
        case kCaptureTypeRightIndexRolled:
            return @"Right Index (Rolled)";
            break;
        case kCaptureTypeRightMiddleRolled:
            return @"Right Middle (Rolled)";
            break;
        case kCaptureTypeRightRingRolled:
            return @"Right Ring (Rolled)";
            break;
        case kCaptureTypeRightLittleRolled:
            return @"Right Little (Rolled)";
            break;
            
        case kCaptureTypeRightThumbFlat:
            return @"Right Thumb";
            break;
        case kCaptureTypeRightIndexFlat:
            return @"Right Index";
            break;
        case kCaptureTypeRightMiddleFlat:
            return @"Right Middle";
            break;
        case kCaptureTypeRightRingFlat:
            return @"Right Ring";
            break;
        case kCaptureTypeRightLittleFlat:
            return @"Right Little";
            break;

        case kCaptureTypeLeftThumbRolled:
            return @"Left Thumb (Rolled)";
            break;
        case kCaptureTypeLeftIndexRolled:
            return @"Left Index (Rolled)";
            break;
        case kCaptureTypeLeftMiddleRolled:
            return @"Left Middle (Rolled)";
            break;
        case kCaptureTypeLeftRingRolled:
            return @"Left Ring (Rolled)";
            break;
        case kCaptureTypeLeftLittleRolled:
            return @"Left Little (Rolled)";
            break;
            
        case kCaptureTypeLeftThumbFlat:
            return @"Left Thumb";
            break;
        case kCaptureTypeLeftIndexFlat:
            return @"Left Index";
            break;
        case kCaptureTypeLeftMiddleFlat:
            return @"Left Middle";
            break;
        case kCaptureTypeLeftRingFlat:
            return @"Left Ring";
            break;
        case kCaptureTypeLeftLittleFlat:
            return @"Left Little";
            break;

        case kCaptureTypeLeftSlap:
            return @"Left Slap";
            break;
        case kCaptureTypeRightSlap:
            return @"Right Slap";
            break;
        case kCaptureTypeThumbsSlap:
            return @"Thumbs Slap";
            break;
            
        //Iris
        case kCaptureTypeLeftIris:
            return @"Left Iris";
            break;
        case kCaptureTypeRightIris:
            return @"Right Iris";
            break;
        case kCaptureTypeBothIrises:
            return @"Both Irises";
            break;
            
        //Face
        case kCaptureTypeFace2d:
            return @"Face";
            break;
        case kCaptureTypeFace3d:
            return @"Face (3D)";
            break;
  
        //Ear
        case kCaptureTypeLeftEar:
            return @"Left Ear";
            break;
        case kCaptureTypeRightEar:
            return @"Right Ear";
            break;
        case kCaptureTypeBothEars:
            return @"Both Ears";
            break;
    
        //Vein
        case kCaptureTypeLeftVein:
            return @"Left Vein";
            break;
        case kCaptureTypeRightVein:
            return @"Right Vein";
            break;
        case kCaptureTypePalm:
            return @"Palm";
            break;
        case kCaptureTypeBackOfHand:
            return @"Back of Hand";
            break;
        case kCaptureTypeWrist:
            return @"Wrist";
            break;

        //Retina
        case kCaptureTypeLeftRetina:
            return @"Left Retina";
            break;
        case kCaptureTypeRightRetina:
            return @"Right Retina";
            break;
        case kCaptureTypeBothRetinas:
            return @"Both Retinas";
            break;
            
        //Foot
        case kCaptureTypeLeftFoot:
            return @"Left Foot";
            break;
        case kCaptureTypeRightFoot:
            return @"Right Foot";
            break;
        case kCaptureTypeBothFeet:
            return @"Both Feet";
            break;

        //Single items
        case kCaptureTypeScent:
            return @"Scent";
            break;
        case kCaptureTypeDNA:
            return @"DNA";
            break;
        case kCaptureTypeHandGeometry:
            return @"Hand Geometry";
            break;
        case kCaptureTypeVoice:
            return @"Voice";
            break;
        case kCaptureTypeGait:
            return @"Gait";
            break;
        case kCaptureTypeKeystroke:
            return @"Keystroke";
            break;
        case kCaptureTypeLipMovement:
            return @"Lip Movement";
            break;
        case kCaptureTypeSignatureSign:
            return @"Signature";
            break;
            
        default:
            break;
    }
    return @"";
}

+(NSString*) stringForModality:(WSSensorModalityType)modalityType
{
    switch (modalityType) {
        case kModalityFace:
            return @"Face";
            break;
        case kModalityIris:
            return @"Iris";
            break;       
        case kModalityFinger:
            return @"Finger";
            break;
        case kModalityEar:
            return @"Ear";
            break;
        case kModalityVein:
            return @"Vein";
            break;
        case kModalityRetina:
            return @"Retina";
            break;
        case kModalityFoot:
            return @"Foot";
            break;
        case kModalityOther:
            return @"Other";
            break;
            
        default:
            break;
    }
    return @"";
}

+(NSString*) parameterNameForCaptureType:(WSSensorCaptureType)captureType
{
    switch (captureType) {
        case kCaptureTypeNotSet:
            return @"";
            break;
            
            //Finger
        case kCaptureTypeRightThumbRolled:
            return @"RightThumbRolled";
            break;
        case kCaptureTypeRightIndexRolled:
            return @"RightIndexRolled";
            break;
        case kCaptureTypeRightMiddleRolled:
            return @"RightMiddleRolled";
            break;
        case kCaptureTypeRightRingRolled:
            return @"RightRingRolled";
            break;
        case kCaptureTypeRightLittleRolled:
            return @"RightLittleRolled";
            break;
            
        case kCaptureTypeRightThumbFlat:
            return @"RightThumbFlat";
            break;
        case kCaptureTypeRightIndexFlat:
            return @"RightIndexFlat";
            break;
        case kCaptureTypeRightMiddleFlat:
            return @"RightMiddleFlat";
            break;
        case kCaptureTypeRightRingFlat:
            return @"RightRingFlat";
            break;
        case kCaptureTypeRightLittleFlat:
            return @"RightLittleFlat";
            break;

        case kCaptureTypeLeftThumbRolled:
            return @"LeftThumbRolled";
            break;
        case kCaptureTypeLeftIndexRolled:
            return @"LeftIndexRolled";
            break;
        case kCaptureTypeLeftMiddleRolled:
            return @"LeftMiddleRolled";
            break;
        case kCaptureTypeLeftRingRolled:
            return @"LeftRingRolled";
            break;
        case kCaptureTypeLeftLittleRolled:
            return @"LeftLittleRolled";
            break;
            
        case kCaptureTypeLeftThumbFlat:
            return @"LeftThumbFlat";
            break;
        case kCaptureTypeLeftIndexFlat:
            return @"LeftIndexFlat";
            break;
        case kCaptureTypeLeftMiddleFlat:
            return @"LeftMiddleFlat";
            break;
        case kCaptureTypeLeftRingFlat:
            return @"LeftRingFlat";
            break;
        case kCaptureTypeLeftLittleFlat:
            return @"LeftLittleFlat";
            break;

            
        case kCaptureTypeLeftSlap:
            return @"LeftSlap";
            break;
        case kCaptureTypeRightSlap:
            return @"RightSlap";
            break;
        case kCaptureTypeThumbsSlap:
            return @"ThumbsSlap";
            break;
            
            //Iris
        case kCaptureTypeLeftIris:
            return @"LeftIris";
            break;
        case kCaptureTypeRightIris:
            return @"RightIris";
            break;
        case kCaptureTypeBothIrises:
            return @"BothIrises";
            break;
            
            //Face
        case kCaptureTypeFace2d:
            return @"Face2d";
            break;
        case kCaptureTypeFace3d:
            return @"Face3d";
            break;
            
            //Ear
        case kCaptureTypeLeftEar:
            return @"LeftEar";
            break;
        case kCaptureTypeRightEar:
            return @"RightEar";
            break;
        case kCaptureTypeBothEars:
            return @"BothEars";
            break;
            
            //Vein
        case kCaptureTypeLeftVein:
            return @"LeftVein";
            break;
        case kCaptureTypeRightVein:
            return @"RightVein";
            break;
        case kCaptureTypePalm:
            return @"Palm";
            break;
        case kCaptureTypeBackOfHand:
            return @"BackOfHand";
            break;
        case kCaptureTypeWrist:
            return @"Wrist";
            break;
            
            //Retina
        case kCaptureTypeLeftRetina:
            return @"LeftRetina";
            break;
        case kCaptureTypeRightRetina:
            return @"RightRetina";
            break;
        case kCaptureTypeBothRetinas:
            return @"BothRetinas";
            break;
            
            //Foot
        case kCaptureTypeLeftFoot:
            return @"LeftFoot";
            break;
        case kCaptureTypeRightFoot:
            return @"RightFoot";
            break;
        case kCaptureTypeBothFeet:
            return @"BothFeet";
            break;
            
            //Single items
        case kCaptureTypeScent:
            return @"Scent";
            break;
        case kCaptureTypeDNA:
            return @"Dna";
            break;
        case kCaptureTypeHandGeometry:
            return @"HandGeometry";
            break;
        case kCaptureTypeVoice:
            return @"Voice";
            break;
        case kCaptureTypeGait:
            return @"Gait";
            break;
        case kCaptureTypeKeystroke:
            return @"Keystroke";
            break;
        case kCaptureTypeLipMovement:
            return @"LipMovement";
            break;
        case kCaptureTypeSignatureSign:
            return @"Signature";
            break;
            
        default:
            break;
    }
    return @"";
}



+(NSArray*) captureTypesForModality:(WSSensorModalityType)modality
{
    switch (modality) {
        case kModalityFace:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeFace2d],
                    [NSNumber numberWithInt:kCaptureTypeFace3d],
                    nil];
            break;
        case kModalityIris:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftIris],
                    [NSNumber numberWithInt:kCaptureTypeRightIris],
                    [NSNumber numberWithInt:kCaptureTypeBothIrises],
                    nil];
            
            break;

        case kModalityFinger:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftSlap],
                    [NSNumber numberWithInt:kCaptureTypeRightSlap],
                    [NSNumber numberWithInt:kCaptureTypeThumbsSlap],

                    [NSNumber numberWithInt:kCaptureTypeLeftThumbFlat],
                    [NSNumber numberWithInt:kCaptureTypeLeftIndexFlat],
                    [NSNumber numberWithInt: kCaptureTypeLeftMiddleFlat],
                    [NSNumber numberWithInt:kCaptureTypeLeftRingFlat],
                    [NSNumber numberWithInt:kCaptureTypeLeftLittleFlat],

                    [NSNumber numberWithInt:kCaptureTypeRightThumbFlat],
                    [NSNumber numberWithInt:kCaptureTypeRightIndexFlat],
                    [NSNumber numberWithInt: kCaptureTypeRightMiddleFlat],
                    [NSNumber numberWithInt:kCaptureTypeRightRingFlat],
                    [NSNumber numberWithInt:kCaptureTypeRightLittleFlat],
                    
                    [NSNumber numberWithInt:kCaptureTypeLeftThumbRolled],
                    [NSNumber numberWithInt:kCaptureTypeLeftIndexRolled],
                    [NSNumber numberWithInt: kCaptureTypeLeftMiddleRolled],
                    [NSNumber numberWithInt:kCaptureTypeLeftRingRolled],
                    [NSNumber numberWithInt:kCaptureTypeLeftLittleRolled],
                    
                    [NSNumber numberWithInt:kCaptureTypeRightThumbRolled],
                    [NSNumber numberWithInt:kCaptureTypeRightIndexRolled],
                    [NSNumber numberWithInt: kCaptureTypeRightMiddleRolled],
                    [NSNumber numberWithInt:kCaptureTypeRightRingRolled],
                    [NSNumber numberWithInt:kCaptureTypeRightLittleRolled],

                    nil];

            break;
        case kModalityEar:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftEar],
                    [NSNumber numberWithInt:kCaptureTypeRightEar],
                    [NSNumber numberWithInt:kCaptureTypeBothEars],
                    nil];

            break;
        case kModalityVein:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftVein],
                    [NSNumber numberWithInt:kCaptureTypeRightVein],
                    [NSNumber numberWithInt:kCaptureTypePalm],
                    [NSNumber numberWithInt:kCaptureTypeBackOfHand],
                    [NSNumber numberWithInt:kCaptureTypeWrist],
                    nil];
            break;
        case kModalityRetina:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftRetina],
                    [NSNumber numberWithInt:kCaptureTypeRightRetina],
                    [NSNumber numberWithInt:kCaptureTypeBothRetinas],
                    nil];

            break;
        case kModalityFoot:
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeLeftFoot],
                    [NSNumber numberWithInt:kCaptureTypeRightFoot],
                    [NSNumber numberWithInt:kCaptureTypeBothFeet],
                    nil];

            break;

        case kModalityOther:
            //return all capture types for now.
            return [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:kCaptureTypeScent],
                    [NSNumber numberWithInt:kCaptureTypeDNA],
                    [NSNumber numberWithInt:kCaptureTypeHandGeometry],
                    [NSNumber numberWithInt:kCaptureTypeVoice],
                    [NSNumber numberWithInt: kCaptureTypeGait],
                    [NSNumber numberWithInt:kCaptureTypeLipMovement],
                    [NSNumber numberWithInt:kCaptureTypeSignatureSign],
                    nil];
            break;
            
        default:
            break;
    }
    return nil;
}

//returns the matching modality number for this string.
+(WSSensorModalityType) modalityForString:(NSString*)modalityName
{
    if ([modalityName isEqualToString:@"Face"]) {
        return kModalityFace;
    }
    else if ([modalityName isEqualToString:@"Iris"]) {
        return kModalityIris;
    }
    else if ([modalityName isEqualToString:@"Finger"]) {
        return kModalityFinger;
    }
    else if ([modalityName isEqualToString:@"Ear"]) {
        return kModalityEar;
    }
    else if ([modalityName isEqualToString:@"Vein"]) {
        return kModalityVein;
    }
    else if ([modalityName isEqualToString:@"Retina"]) {
        return kModalityRetina;
    }
    else if ([modalityName isEqualToString:@"Foot"]) {
        return kModalityFoot;
    }
    else if ([modalityName isEqualToString:@"Other"]) {
        return kModalityOther;
    }
    else
        return 0;

}

//returns the matching capture type number for this string.
+(WSSensorCaptureType) captureTypeForString:(NSString*)captureTypeName
{
    
    if ([captureTypeName isEqualToString:@"Right Thumb (Rolled)"]) {
        return kCaptureTypeRightThumbRolled;
    }
    else if ([captureTypeName isEqualToString:@"Right Index (Rolled)"]) {
        return kCaptureTypeRightIndexRolled;
    }
    else if ([captureTypeName isEqualToString:@"Right Middle (Rolled)"]) {
        return kCaptureTypeRightMiddleRolled;
    }
    else if ([captureTypeName isEqualToString:@"Right Ring (Rolled)"]) {
        return kCaptureTypeRightRingRolled;
    }
    else if ([captureTypeName isEqualToString:@"Right Little (Rolled)"]) {
        return kCaptureTypeRightLittleRolled;
    }
 
    else if ([captureTypeName isEqualToString:@"Right Thumb"]) {
        return kCaptureTypeRightThumbFlat;
    }
    else if ([captureTypeName isEqualToString:@"Right Index"]) {
        return kCaptureTypeRightIndexFlat;
    }
    else if ([captureTypeName isEqualToString:@"Right Middle"]) {
        return kCaptureTypeRightMiddleFlat;
    }
    else if ([captureTypeName isEqualToString:@"Right Ring"]) {
        return kCaptureTypeRightRingFlat;
    }
    else if ([captureTypeName isEqualToString:@"Right Little"]) {
        return kCaptureTypeRightLittleFlat;
    }

    else if ([captureTypeName isEqualToString:@"Left Thumb (Rolled)"]) {
        return kCaptureTypeLeftThumbRolled;
    }
    else if ([captureTypeName isEqualToString:@"Left Index (Rolled)"]) {
        return kCaptureTypeLeftIndexRolled;
    }
    else if ([captureTypeName isEqualToString:@"Left Middle (Rolled)"]) {
        return kCaptureTypeLeftMiddleRolled;
    }
    else if ([captureTypeName isEqualToString:@"Left Ring (Rolled)"]) {
        return kCaptureTypeLeftRingRolled;
    }
    else if ([captureTypeName isEqualToString:@"Left Little (Rolled)"]) {
        return kCaptureTypeLeftLittleRolled;
    }
    
    else if ([captureTypeName isEqualToString:@"Left Thumb"]) {
        return kCaptureTypeLeftThumbFlat;
    }
    else if ([captureTypeName isEqualToString:@"Left Index"]) {
        return kCaptureTypeLeftIndexFlat;
    }
    else if ([captureTypeName isEqualToString:@"Left Middle"]) {
        return kCaptureTypeLeftMiddleFlat;
    }
    else if ([captureTypeName isEqualToString:@"Left Ring"]) {
        return kCaptureTypeLeftRingFlat;
    }
    else if ([captureTypeName isEqualToString:@"Left Little"]) {
        return kCaptureTypeLeftLittleFlat;
    }

                
    else if ([captureTypeName isEqualToString:@"Left Slap"]) {
        return kCaptureTypeLeftSlap;
    }
    else if ([captureTypeName isEqualToString:@"Right Slap"]) {
        return kCaptureTypeRightSlap;
    }
    else if ([captureTypeName isEqualToString:@"Thumbs Slap"]) {
        return kCaptureTypeThumbsSlap;
    }
                
    //Iris
    else if ([captureTypeName isEqualToString:@"Left Iris"]) {
        return kCaptureTypeLeftIris;
    }
    else if ([captureTypeName isEqualToString:@"Right Iris"]) {
        return kCaptureTypeRightIris;
    }
    else if ([captureTypeName isEqualToString:@"Both Irises"]) {
        return kCaptureTypeBothIrises;
    }
             
    //Face
    else if ([captureTypeName isEqualToString:@"Face"]) {
        return kCaptureTypeFace2d;
    }
    else if ([captureTypeName isEqualToString:@"Face (3D)"]) {
        return kCaptureTypeFace3d;
    }

    //Ear
    else if ([captureTypeName isEqualToString:@"leftEar"]) {
        return kCaptureTypeLeftEar;
    }
    else if ([captureTypeName isEqualToString:@"rightEar"]) {
        return kCaptureTypeRightEar;
    }
    else if ([captureTypeName isEqualToString:@"bothEars"]) {
        return kCaptureTypeBothEars;
    }
            
    //Vein
    else if ([captureTypeName isEqualToString:@"Left Vein"]) {
        return kCaptureTypeLeftVein;
    }
    else if ([captureTypeName isEqualToString:@"Right Vein"]) {
        return kCaptureTypeRightVein;
    }
    else if ([captureTypeName isEqualToString:@"Palm"]) {
        return kCaptureTypePalm;
    }
    else if ([captureTypeName isEqualToString:@"Back of Hand"]) {
        return kCaptureTypeBackOfHand;
    }
    else if ([captureTypeName isEqualToString:@"Wrist"]) {
        return kCaptureTypeWrist;
    }

                    
    //Retina
    else if ([captureTypeName isEqualToString:@"Left Retina"]) {
        return kCaptureTypeLeftRetina;
    }
    else if ([captureTypeName isEqualToString:@"Right Retina"]) {
        return kCaptureTypeRightRetina;
    }
    else if ([captureTypeName isEqualToString:@"Both Retinas"]) {
        return kCaptureTypeBothRetinas;
    }

    //Foot
    else if ([captureTypeName isEqualToString:@"Left Foot"]) {
        return kCaptureTypeLeftFoot;
    }
    else if ([captureTypeName isEqualToString:@"Right Foot"]) {
        return kCaptureTypeRightFoot;
    }
    else if ([captureTypeName isEqualToString:@"Both Feet"]) {
        return kCaptureTypeBothFeet;
    }

                //Single items
    else if ([captureTypeName isEqualToString:@"Scent"]) {
        return kCaptureTypeScent;
    }
    else if ([captureTypeName isEqualToString:@"DNA"]) {
        return kCaptureTypeDNA;
    }
    else if ([captureTypeName isEqualToString:@"Hand Geometry"]) {
        return kCaptureTypeHandGeometry;
    }
    else if ([captureTypeName isEqualToString:@"Voice"]) {
        return kCaptureTypeVoice;
    }
    else if ([captureTypeName isEqualToString:@"Gait"]) {
        return kCaptureTypeGait;
    } 
    else if ([captureTypeName isEqualToString:@"Keystroke"]) {
        return kCaptureTypeKeystroke;
    }
    else if ([captureTypeName isEqualToString:@"Lip Movement"]) {
        return kCaptureTypeLipMovement;
    }
    else if ([captureTypeName isEqualToString:@"Signature"]) {
        return kCaptureTypeSignatureSign;
    }

    else return kCaptureTypeNotSet;
}


@end
