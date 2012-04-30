//
//  NSObject+GCDBlocks.h
//  wsabi2
//
//  Created by Matt Aronoff on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GCDBlocks)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
