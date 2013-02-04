//
//  WSCDPerson.h
//  wsabi2
//
//  Created by Matt Aronoff on 5/23/12.
 
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WSCDItem;

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

- (void)addItemsObject:(WSCDItem *)value;
- (void)removeItemsObject:(WSCDItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
