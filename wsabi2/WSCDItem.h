//
//  WSCDItem.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WSCDDeviceDefinition, WSCDPerson;

@interface WSCDItem : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * dataContentType;
@property (nonatomic, retain) NSString * modality;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * submodality;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) WSCDDeviceDefinition *deviceConfig;
@property (nonatomic, retain) WSCDPerson *person;

@end
