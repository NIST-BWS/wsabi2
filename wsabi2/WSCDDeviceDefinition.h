//
//  WSCDDeviceDefinition.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WSCDItem;

@interface WSCDDeviceDefinition : NSManagedObject

@property (nonatomic, retain) NSString * mostRecentSessionId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * parameterDictionary;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) WSCDItem *item;

@end
