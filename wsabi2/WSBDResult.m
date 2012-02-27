//
//  WSBDResult.m
//  Wsabi
//
//  Created by Matt Aronoff on 7/23/10.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import "WSBDResult.h"


@implementation WSBDResult

@synthesize status, message;
@synthesize sessionId, captureIds, infoCommon, infoDetailed, config, resultCount, contentType, downloadData;

+(NSString*)stringForStatusValue:(StatusValue)value
{
    NSString *result = nil;
    /*
     StatusSuccess=1,
     StatusFailure=2,
     StatusInvalidId=3,
     StatusCancelled=4,
     StatusCancelledWithSensorFailure=5,
     StatusSensorFailure=6,
     StatusLockNotHeld=7,
     StatusLockHeldByAnother=8,
     StatusSensorNeedsInitialization=9,
     StatusSensorNeedsConfiguration=10,
     StatusSensorBusy=11,
     StatusSensorTimeout=12,
     StatusUnsupported=13,
     StatusBadValue=14,
     StatusNoSuchParameter=15,
     StatusPreparingDownload=16

     */
    switch (value) {
        case StatusSuccess:
            result = @"Success";
            break;
        case StatusFailure:
            result = @"Failure";
            break;
        case StatusInvalidId:
            result = @"Invalid ID";
            break;
        case StatusCancelled:
            result = @"Cancelled";
            break;
        case StatusCancelledWithSensorFailure:
            result = @"Cancelled with Sensor Failure";
            break;
        case StatusSensorFailure:
            result = @"Sensor Failure";
            break;
        case StatusLockNotHeld:
            result = @"Lock Not Held";
            break;
        case StatusLockHeldByAnother:
            result = @"Lock Held by Another";
            break;
        case StatusSensorNeedsInitialization:
            result = @"Sensor Needs Initialization";
            break;
        case StatusSensorNeedsConfiguration:
            result = @"Sensor Needs Configuration";
            break;
        case StatusSensorBusy:
            result = @"Sensor Busy";
            break;
        case StatusSensorTimeout:
            result = @"Sensor Timeout";
            break;
        case StatusUnsupported:
            result = @"Unsupported";
            break;
        case StatusBadValue:
            result = @"Bad Value";
            break;
        case StatusNoSuchParameter:
            result = @"No Such Parameter";
            break;
        case StatusPreparingDownload:
            result = @"Preparing Download";
            break;
        default:
            break;
    }
    return result;
}

//#pragma mark -
//#pragma mark Memory management
//
//- (void)dealloc {
//	[message release];
//	
//	[sessionId release];
//	[captureIds release];
//	[infoCommon release];
//	[infoDetailed release];
//	[config release];
//	[contentType release];
//	[downloadData release];
//	
//	[super dealloc];
//}

@end
