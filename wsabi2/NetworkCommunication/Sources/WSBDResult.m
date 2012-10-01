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
@synthesize sessionId, captureIds, metadata, config, resultCount, contentType, downloadData;

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
            result = @"success";
            break;
        case StatusFailure:
            result = @"failure";
            break;
        case StatusInvalidId:
            result = @"invalid ID";
            break;
        case StatusCancelled:
            result = @"cancelled";
            break;
        case StatusCancelledWithSensorFailure:
            result = @"cancelled with sensor failure";
            break;
        case StatusSensorFailure:
            result = @"sensor failure";
            break;
        case StatusLockNotHeld:
            result = @"lock not held";
            break;
        case StatusLockHeldByAnother:
            result = @"lock held by another";
            break;
        case StatusSensorNeedsInitialization:
            result = @"sensor needs initialization";
            break;
        case StatusSensorNeedsConfiguration:
            result = @"sensor needs configuration";
            break;
        case StatusSensorBusy:
            result = @"sensor busy";
            break;
        case StatusSensorTimeout:
            result = @"sensor timeout";
            break;
        case StatusUnsupported:
            result = @"unsupported";
            break;
        case StatusBadValue:
            result = @"bad value";
            break;
        case StatusNoSuchParameter:
            result = @"no such parameter";
            break;
        case StatusPreparingDownload:
            result = @"preparing download";
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
