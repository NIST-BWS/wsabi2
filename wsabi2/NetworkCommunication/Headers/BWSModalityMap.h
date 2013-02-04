// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>
#import "BWSConstants.h"

@interface BWSModalityMap : NSObject {
    
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
