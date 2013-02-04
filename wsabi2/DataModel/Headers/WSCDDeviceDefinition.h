//
//  WSCDDeviceDefinition.h
//  wsabi2
//
//  Created by Matt Aronoff on 5/23/12.
 
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BWSCDItem;

@interface WSCDDeviceDefinition : NSManagedObject

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
