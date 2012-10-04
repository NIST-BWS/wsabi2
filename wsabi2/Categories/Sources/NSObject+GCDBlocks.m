//
//  NSObject+GCDBlocks.m
//  wsabi2
//
//  Created by Matt Aronoff on 4/30/12.
 
//

//NOTE: Taken almost verbatim from http://forrst.com/posts/Delayed_Blocks_in_Objective_C-0Fn

#import "NSObject+GCDBlocks.h"

@implementation NSObject (GCDBlocks)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    int64_t delta = (int64_t)(1.0e9 * delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

@end
