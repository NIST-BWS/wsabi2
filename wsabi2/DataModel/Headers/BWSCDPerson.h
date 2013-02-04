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

@interface BWSCDPerson : NSManagedObject

@property (nonatomic, retain) NSData * aliases;
@property (nonatomic, retain) NSData * datesOfBirth;
@property (nonatomic, retain) NSString * eyeColor;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * hairColor;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * otherName;
@property (nonatomic, retain) NSData * placesOfBirth;
@property (nonatomic, retain) NSString * race;
@property (nonatomic, retain) NSDate * timeStampCreated;
@property (nonatomic, retain) NSDate * timeStampLastModified;
@property (nonatomic, retain) NSString * weight;
@property (nonatomic, retain) NSSet *items;
@end

@interface BWSCDPerson (CoreDataGeneratedAccessors)

- (void)addItemsObject:(BWSCDItem *)value;
- (void)removeItemsObject:(BWSCDItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
