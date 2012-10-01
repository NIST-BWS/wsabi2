//
//  WSBDModalityMap.h
//  Wsabi
//
//  Created by Matt Aronoff on 2/10/11.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface WSModalityMap : NSObject {
    
}

//Returns a pretty name for this capture type
+(NSString*) stringForCaptureType:(WSSensorCaptureType)captureType;

//Returns the parameter name (for use in setting configurations) for this capture type
+(NSString*) parameterNameForCaptureType:(WSSensorCaptureType)captureType;

+(NSString*) stringForModality:(WSSensorModalityType)modalityType;

+(NSArray*) captureTypesForModality:(WSSensorModalityType)modality;

//returns the matching modality number for this string.
+(WSSensorModalityType) modalityForString:(NSString*)modalityName;

//returns the matching capture type number for this string.
+(WSSensorCaptureType) captureTypeForString:(NSString*)captureTypeName;

@end
