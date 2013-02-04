//
//  WSCDItem.h
//  wsabi2
//
//  Created by Matt Aronoff on 5/23/12.
 
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WSCDDeviceDefinition, BWSCDPerson;

@interface WSCDItem : NSManagedObject

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
@property (nonatomic, retain) WSCDDeviceDefinition *deviceConfig;
@property (nonatomic, retain) BWSCDPerson *person;

@end
