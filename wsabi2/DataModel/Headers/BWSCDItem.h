// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BWSCDDeviceDefinition, BWSCDPerson;

@interface BWSCDItem : NSManagedObject

@property (nonatomic, retain) NSData * annotations;
@property (nonatomic, retain) NSData * captureMetadata;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * dataContentType;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * modality;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * submodality;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * timeStampCreated;
@property (nonatomic, retain) BWSCDDeviceDefinition *deviceConfig;
@property (nonatomic, retain) BWSCDPerson *person;

@end
