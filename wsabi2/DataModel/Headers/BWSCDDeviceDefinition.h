// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BWSCDItem;

@interface BWSCDDeviceDefinition : NSManagedObject

@property (nonatomic, retain) NSNumber * inactivityTimeout;
@property (nonatomic, retain) NSString * modalities;
@property (nonatomic, retain) NSString * mostRecentSessionId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * parameterDictionary;
@property (nonatomic, retain) NSString * submodalities;
@property (nonatomic, retain) NSDate * timeStampLastEdit;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) BWSCDItem *item;

@end
