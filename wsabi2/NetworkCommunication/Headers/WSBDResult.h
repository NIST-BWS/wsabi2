// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.


#import <Foundation/Foundation.h>

//Define an enum for possible status return values
typedef enum {
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
} StatusValue;


@interface WSBDResult : NSObject {
	StatusValue status;
	NSString *message;

	NSString *sessionId;
	NSMutableArray *captureIds;
	NSMutableDictionary *metadata;
	NSMutableDictionary *config;
	int resultCount;
	NSString *contentType;
	id downloadData;
    
}

+(NSString*)stringForStatusValue:(StatusValue)value;

@property (nonatomic) StatusValue status;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSMutableArray *captureIds;

@property (nonatomic, strong) NSMutableDictionary *metadata;
@property (nonatomic, strong) NSMutableDictionary *config;
@property (nonatomic) int resultCount;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) id downloadData;


@end
