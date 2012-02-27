//
//  UserTesting.h
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (UserTesting)

+(void) appendUserTestingStringToCurrentLog:(NSString*)theString;
+(BOOL) startNewUserTestingFile;

-(UIImage*) screenshot;

@end
