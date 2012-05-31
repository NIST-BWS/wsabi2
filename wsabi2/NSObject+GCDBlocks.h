//
//  NSObject+GCDBlocks.h
//  wsabi2
//
//  Created by Matt Aronoff on 4/30/12.
 
//

#import <Foundation/Foundation.h>

@interface NSObject (GCDBlocks)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
