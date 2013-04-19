// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "WSBDResult.h"

@implementation WSBDResult

+ (NSString *)stringForStatusValue:(StatusValue)value
{
    switch (value) {
        case StatusSuccess:
            return (@"success");
        case StatusFailure:
            return (@"failure");
        case StatusInvalidId:
            return (@"invalid ID");
        case StatusCancelled:
            return (@"cancelled");
        case StatusCancelledWithSensorFailure:
            return (@"cancelled with sensor failure");
        case StatusSensorFailure:
            return (@"sensor failure");
        case StatusLockNotHeld:
            return (@"lock not held");
        case StatusLockHeldByAnother:
            return (@"lock held by another");
        case StatusSensorNeedsInitialization:
            return (@"sensor needs initialization");
        case StatusSensorNeedsConfiguration:
            return (@"sensor needs configuration");
        case StatusSensorBusy:
            return (@"sensor busy");
        case StatusSensorTimeout:
            return (@"sensor timeout");
        case StatusUnsupported:
            return (@"unsupported");
        case StatusBadValue:
            return (@"bad value");
        case StatusNoSuchParameter:
            return (@"no such parameter");
        case StatusPreparingDownload:
            return (@"preparing download");
        default:
            return (nil);
    }
}

@end
