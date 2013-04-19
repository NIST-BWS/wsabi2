// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>

/// Possible status return values
typedef NS_ENUM(NSUInteger, StatusValue)
{
    StatusValueUnknownStatusValue,
	StatusSuccess,
	StatusFailure,
	StatusInvalidId,
	StatusCanceled,
	StatusCanceledWithSensorFailure,
	StatusSensorFailure,
	StatusLockNotHeld,
	StatusLockHeldByAnother,
	StatusSensorNeedsInitialization,
	StatusSensorNeedsConfiguration,
	StatusSensorBusy,
	StatusSensorTimeout,
	StatusUnsupported,
	StatusBadValue,
	StatusNoSuchParameter,
	StatusPreparingDownload
};

@interface WSBDResult : NSObject {}

/// @return Human-readable string representing the status
+ (NSString *)stringForStatusValue:(StatusValue)value;
/// @param statusString Value of status of an XML Result
+ (StatusValue)statusValueForStatusString:(NSString *)statusString;

@property (nonatomic, assign) StatusValue status;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSMutableArray *captureIds;

@property (nonatomic, strong) NSMutableDictionary *metadata;
@property (nonatomic, strong) NSMutableDictionary *config;
@property (nonatomic, assign) NSInteger resultCount;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) id downloadData;

@end
